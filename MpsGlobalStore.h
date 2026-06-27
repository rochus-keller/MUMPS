#ifndef MPSGLOBALSTORE_H
#define MPSGLOBALSTORE_H

/*
* Copyright 2026 Rochus Keller <mailto:me@rochus-keller.ch>
*
* This file is part of the MUMPS 76 project.
*
* The following is the license that applies to this copy of the
* file. For a license to use the file under conditions
* other than those described here, please email to me@rochus-keller.ch.
*
* GNU General Public License Usage
* This file may be used under the terms of the GNU General Public
* License (GPL) versions 2.0 or 3.0 as published by the Free Software
* Foundation and appearing in the file LICENSE.GPL included in
* the packaging of this file. Please review the following information
* to ensure GNU General Public Licensing requirements will be met:
* http://www.fsf.org/licensing/licenses/info/GPLv2.html and
* http://www.gnu.org/copyleft/gpl.html.
*/

#include <QByteArray>
#include <QList>
#include <QString>
#include <QFile>
#include <QMap>

namespace Mps
{

class GlobalStore
{
public:
    GlobalStore();
    ~GlobalStore();

    bool open(const QString& path);
    void close();
    bool isOpen() const;

    void set(const QByteArray& global, const QList<QByteArray>& subs, const QByteArray& value);
    QByteArray get(const QByteArray& global, const QList<QByteArray>& subs) const;
    int data(const QByteArray& global, const QList<QByteArray>& subs) const;
    QByteArray order(const QByteArray& global, const QList<QByteArray>& subs,
                     const QByteArray& startAfter, int direction = 1) const;
    void kill(const QByteArray& global, const QList<QByteArray>& subs);
    void killAll(const QByteArray& global);

    QByteArray nextGlobal(const QByteArray& after) const;

    enum { DefaultBlockSize = 1024 };

private:
    struct FileHeader // block 0
    {
        quint32 magic;
        quint16 version;
        quint16 blockSize;   // default 1024
        quint32 totalBlocks; // number of blocks in the file
        quint32 freeListHead;   // block ID of first free block or 0
        quint32 globalDirBlock; // block ID of global directory head block
        FileHeader():magic(0), version(0), blockSize(0),
            totalBlocks(0), freeListHead(0), globalDirBlock(0) {}
    };

    enum { BlockHeaderSize = 4 }; // uint16+uint8+uint8
    enum BlockType { BlockFree = 0, BlockData = 1, BlockGlobalDir = 2 };
    // Block layout on disk:
    //   usedBytes: uint16, including header, excluding continuation pointer
    //   blockType: uint8  -> BlockType
    //   reserved: uint8
    //   { nodes }
    //   last 4 bytes of block: continuation pointer or 0: uint32

    enum NodeType { NodeValue = 1, // value only, no children
                    NodePointer = 2, // pointer only, with children
                    NodePointerValue = 3 // pointer and value, with children
                  };
    // Node layout on disk:
    //   type: uint8 -> NodeType
    //   subscriptLen: uint16
    //   subscript: bytes
    //   downPointer (uint32) or value (len: uint16 + bytes)

    struct CacheEntry
    {
        QByteArray data;
        quint32 blockId;
        bool dirty;
        CacheEntry() : blockId(0), dirty(false) {}
    };

    QByteArray readBlock(quint32 blockId) const;
    void writeBlock(quint32 blockId, const QByteArray& data);
    quint32 allocBlock();
    void freeBlock(quint32 blockId);
    quint32 appendNewBlock();

    static quint16 blockUsedBytes(const QByteArray& block);
    static void setBlockUsedBytes(QByteArray& block, quint16 used);
    static quint8 blockType(const QByteArray& block);
    static void setBlockType(QByteArray& block, quint8 type);
    quint32 blockContPtr(const QByteArray& block) const;
    void setBlockContPtr(QByteArray& block, quint32 ptr) const;
    int payloadCapacity() const; // block size - header - cont. ptr

    struct NodeEntry
    {
        quint8 type;
        QByteArray subscript;
        quint32 downPtr; // TODO: downPtr or value variant
        QByteArray value;
        int byteSize() const;
        NodeEntry():type(0), downPtr(0) {}
    };
    QList<NodeEntry> parseEntries(const QByteArray& block) const;
    QByteArray serializeEntries(const QList<NodeEntry>& entries,
                                quint8 btype, quint32 contPtr) const;

    bool findInChain(quint32 headBlock, const QByteArray& subscript, NodeEntry& result) const;
    void insertInChain(quint32 headBlock, const NodeEntry& entry);
    quint32 removeFromChain(quint32 headBlock, const QByteArray& subscript);
    QByteArray orderInChain(quint32 headBlock, const QByteArray& after, int direction) const;
    bool chainHasNodes(quint32 headBlock) const;

    quint32 findLevel(quint32 dirHeadBlock, const QByteArray& global,
                      const QList<QByteArray>& subs, int depth) const;

    void killChain(quint32 headBlock); // Free all blocks in a chain incl. child levels

    quint32 ensurePath(quint32 dirHeadBlock, const QByteArray& global,
                       const QList<QByteArray>& subs, int depth);

    quint32 findGlobalHeadBlock(const QByteArray& global) const;
    quint32 getOrCreateGlobalEntry(const QByteArray& global);
    void removeGlobalEntry(const QByteArray& global);

    static int compareSubscripts(const QByteArray& a, const QByteArray& b);

    void flushCache(); // to disk

    FileHeader d_header;
    mutable QFile d_file;
    mutable QMap<quint32, CacheEntry> d_cache;
    bool d_isOpen;
    quint16 d_blockSize;
};

}

#endif // MPSGLOBALSTORE_H
