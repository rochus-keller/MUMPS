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


/*
   Implementation of Wasserman, Sherertz, Rogerson (1975):
   "MUMPS Globals and their Implementation" [MGI75]

   - Fixed-size blocks stored in a flat file
   - Each level of the global tree is a chain of blocks linked by
     continuation pointers (last 4 bytes of each block)
   - Parent nodes contain "down pointers" to the head block
      of their children's level
   - A global directory block serves as the top-level entry point,
     holding one entry per global name with a down pointer
     to the first-level head block
   - Nodes within a block are kept sorted by Mumps subscript collation
   - Free blocks are maintained in a linked list
*/

#include "MpsGlobalStore.h"
#include "MpsCollation.h"
#include <QDataStream>
#include <QIODevice>
using namespace Mps;


static quint16 readU16(const QByteArray& buf, int offset)
{
    if( offset + 1 >= buf.size() )
        return 0;
    return (quint8)buf[offset] | ((quint16)(quint8)buf[offset + 1] << 8);
}

static void writeU16(QByteArray& buf, int offset, quint16 val)
{
    buf[offset] = (char)(val & 0xFF);
    buf[offset + 1] = (char)((val >> 8) & 0xFF);
}

static quint32 readU32(const QByteArray& buf, int offset)
{
    if( offset + 3 >= buf.size() )
        return 0;
    else
        return (quint8)buf[offset] | ((quint32)(quint8)buf[offset + 1] << 8)
            | ((quint32)(quint8)buf[offset + 2] << 16) | ((quint32)(quint8)buf[offset + 3] << 24);
}

static void writeU32(QByteArray& buf, int offset, quint32 val)
{
    buf[offset] = (char)(val & 0xFF);
    buf[offset + 1] = (char)((val >> 8) & 0xFF);
    buf[offset + 2] = (char)((val >> 16) & 0xFF);
    buf[offset + 3] = (char)((val >> 24) & 0xFF);
}

int GlobalStore::NodeEntry::byteSize() const
{
    // total serialized size: type(1) + subscriptLen(2) + subscript + [downPtr(4)] + [valueLen(2) + value]
    int sz = 1 + 2 + subscript.size();
    if( type & NodePointer )
        sz += 4;
    if( type & NodeValue )
        sz += 2 + value.size();
    return sz;
}

GlobalStore::GlobalStore():d_isOpen(false), d_blockSize(DefaultBlockSize)
{
}

GlobalStore::~GlobalStore()
{
    if( d_isOpen )
        close();
}

bool GlobalStore::open(const QString& path)
{
    if( d_isOpen )
        close();

    d_file.setFileName(path);

    if( d_file.exists() )
    {
        if( !d_file.open(QIODevice::ReadWrite) )
            return false;

        QByteArray headerBlock = readBlock(0);
        d_header.magic = readU32(headerBlock, 0);
        d_header.version = readU16(headerBlock, 4);
        d_header.blockSize = readU16(headerBlock, 6);
        d_header.totalBlocks = readU32(headerBlock, 8);
        d_header.freeListHead = readU32(headerBlock, 12);
        d_header.globalDirBlock = readU32(headerBlock, 16);

        if( d_header.magic != 0x4750534D )  // "MPSG" little-endian
        {
            d_file.close();
            return false;
        }
        d_blockSize = d_header.blockSize;
    }else
    {
        // new database
        if( !d_file.open(QIODevice::ReadWrite) )
            return false;

        d_blockSize = DefaultBlockSize;

        d_header.magic = 0x4750534D;
        d_header.version = 1;
        d_header.blockSize = d_blockSize;
        d_header.totalBlocks = 2;  // header + global directory
        d_header.freeListHead = 0;
        d_header.globalDirBlock = 1;

        QByteArray headerBlock(d_blockSize, '\0');
        writeU32(headerBlock, 0, d_header.magic);
        writeU16(headerBlock, 4, d_header.version);
        writeU16(headerBlock, 6, d_header.blockSize);
        writeU32(headerBlock, 8, d_header.totalBlocks);
        writeU32(headerBlock, 12, d_header.freeListHead);
        writeU32(headerBlock, 16, d_header.globalDirBlock);
        writeBlock(0, headerBlock);

        // empty global directory block
        QByteArray dirBlock(d_blockSize, '\0');
        setBlockUsedBytes(dirBlock, BlockHeaderSize);
        setBlockType(dirBlock, BlockGlobalDir);
        setBlockContPtr(dirBlock, 0);
        writeBlock(1, dirBlock);
    }

    d_isOpen = true;
    return true;
}

void GlobalStore::close()
{
    if( !d_isOpen )
        return;

    flushCache();

    // update header
    QByteArray headerBlock(d_blockSize, '\0');
    writeU32(headerBlock, 0, d_header.magic);
    writeU16(headerBlock, 4, d_header.version);
    writeU16(headerBlock, 6, d_header.blockSize);
    writeU32(headerBlock, 8, d_header.totalBlocks);
    writeU32(headerBlock, 12, d_header.freeListHead);
    writeU32(headerBlock, 16, d_header.globalDirBlock);

    d_file.seek(0);
    d_file.write(headerBlock);
    d_file.flush();
    d_file.close();

    d_cache.clear();
    d_isOpen = false;
}

bool GlobalStore::isOpen() const
{
    return d_isOpen;
}

QByteArray GlobalStore::readBlock(quint32 blockId) const
{
    // Check cache first
    QMap<quint32, CacheEntry>::const_iterator it = d_cache.find(blockId);
    if( it != d_cache.end() )
        return it.value().data;

    // Read from file
    qint64 offset = (qint64)blockId * d_blockSize;
    d_file.seek(offset);
    QByteArray data = d_file.read(d_blockSize);
    if( data.size() < d_blockSize )
        data.resize(d_blockSize);  // pad if short

    // Cache it
    CacheEntry entry;
    entry.data = data;
    entry.blockId = blockId;
    entry.dirty = false;
    d_cache.insert(blockId, entry);

    return data;
}

void GlobalStore::writeBlock(quint32 blockId, const QByteArray& data)
{
    CacheEntry entry;
    entry.data = data;
    entry.blockId = blockId;
    entry.dirty = true;
    d_cache.insert(blockId, entry);
}

quint32 GlobalStore::allocBlock()
{
    if( d_header.freeListHead != 0 )
    {
        quint32 blockId = d_header.freeListHead;
        QByteArray block = readBlock(blockId);
        // Free block: next free pointer stored at offset 4
        d_header.freeListHead = readU32(block, 4);
        // Clear the block
        block.fill('\0');
        setBlockUsedBytes(block, BlockHeaderSize);
        setBlockType(block, BlockData);
        setBlockContPtr(block, 0);
        writeBlock(blockId, block);
        return blockId;
    }
    return appendNewBlock();
}

void GlobalStore::freeBlock(quint32 blockId)
{
    QByteArray block(d_blockSize, '\0');
    setBlockType(block, BlockFree);
    writeU32(block, 4, d_header.freeListHead);  // next free pointer
    d_header.freeListHead = blockId;
    writeBlock(blockId, block);
}

quint32 GlobalStore::appendNewBlock()
{
    quint32 blockId = d_header.totalBlocks;
    d_header.totalBlocks++;

    QByteArray block(d_blockSize, '\0');
    setBlockUsedBytes(block, BlockHeaderSize);
    setBlockType(block, BlockData);
    setBlockContPtr(block, 0);
    writeBlock(blockId, block);
    return blockId;
}

void GlobalStore::flushCache()
{
    QMap<quint32, CacheEntry>::iterator it;
    for( it = d_cache.begin(); it != d_cache.end(); ++it )
    {
        if( it.value().dirty )
        {
            qint64 offset = (qint64)it.value().blockId * d_blockSize;
            d_file.seek(offset);
            d_file.write(it.value().data);
            it.value().dirty = false;
        }
    }
    d_file.flush();
}

quint16 GlobalStore::blockUsedBytes(const QByteArray& block)
{
    return readU16(block, 0);
}

void GlobalStore::setBlockUsedBytes(QByteArray& block, quint16 used)
{
    writeU16(block, 0, used);
}

quint8 GlobalStore::blockType(const QByteArray& block)
{
    return (quint8)block[2];
}

void GlobalStore::setBlockType(QByteArray& block, quint8 type)
{
    block[2] = (char)type;
}

quint32 GlobalStore::blockContPtr(const QByteArray& block) const
{
    return readU32(block, d_blockSize - 4);
}

void GlobalStore::setBlockContPtr(QByteArray& block, quint32 ptr) const
{
    writeU32(block, d_blockSize - 4, ptr);
}

int GlobalStore::payloadCapacity() const
{
    // Block size minus header (4 bytes) minus continuation pointer (4 bytes)
    return d_blockSize - BlockHeaderSize - 4;
}

QList<GlobalStore::NodeEntry> GlobalStore::parseEntries(const QByteArray& block) const
{
    QList<NodeEntry> entries;
    int used = blockUsedBytes(block);
    int pos = BlockHeaderSize;

    while( pos < used )
    {
        if( pos >= d_blockSize - 4 )
            break;  // reached continuation pointer area

        NodeEntry e;
        e.type = (quint8)block[pos]; pos++;
        if( e.type == 0 )
            break;  // end marker

        if( pos + 2 > used ) break;
        quint16 subLen = readU16(block, pos); pos += 2;
        if( pos + subLen > used ) break;
        e.subscript = block.mid(pos, subLen); pos += subLen;

        if( e.type & NodePointer )
        {
            if( pos + 4 > used ) break;
            e.downPtr = readU32(block, pos); pos += 4;
        }
        else
        {
            e.downPtr = 0;
        }

        if( e.type & NodeValue )
        {
            if( pos + 2 > used ) break;
            quint16 valLen = readU16(block, pos); pos += 2;
            if( pos + valLen > used ) break;
            e.value = block.mid(pos, valLen); pos += valLen;
        }

        entries.append(e);
    }

    return entries;
}

QByteArray GlobalStore::serializeEntries(const QList<NodeEntry>& entries,
                                          quint8 btype, quint32 contPtr) const
{
    QByteArray block(d_blockSize, '\0');
    setBlockType(block, btype);
    setBlockContPtr(block, contPtr);

    int pos = BlockHeaderSize;
    for( int i = 0; i < entries.size(); i++ )
    {
        const NodeEntry& e = entries[i];
        int needed = e.byteSize();
        if( pos + needed > d_blockSize - 4 )
            break;  // shouldn't happen if caller checked capacity

        block[pos] = (char)e.type; pos++;
        writeU16(block, pos, e.subscript.size()); pos += 2;
        for( int j = 0; j < e.subscript.size(); j++ )
            block[pos + j] = e.subscript[j];
        pos += e.subscript.size();

        if( e.type & NodePointer )
        {
            writeU32(block, pos, e.downPtr); pos += 4;
        }
        if( e.type & NodeValue )
        {
            writeU16(block, pos, e.value.size()); pos += 2;
            for( int j = 0; j < e.value.size(); j++ )
                block[pos + j] = e.value[j];
            pos += e.value.size();
        }
    }

    setBlockUsedBytes(block, pos);
    return block;
}

int GlobalStore::compareSubscripts(const QByteArray& a, const QByteArray& b)
{
    return Collation::compare(a, b);
}

bool GlobalStore::findInChain(quint32 headBlock, const QByteArray& subscript,
                               NodeEntry& result) const
{
    /* [MGI75] 3.3.1: "Compare the subscript reference with the subscript value
        in the global node. If there is a match, proceed; otherwise, go to the
         next node in that disc block or to the first node in the continuation
         block if that block is exhausted." */
    quint32 curBlock = headBlock;
    while( curBlock != 0 )
    {
        QByteArray block = readBlock(curBlock);
        QList<NodeEntry> entries = parseEntries(block);

        for( int i = 0; i < entries.size(); i++ )
        {
            int cmp = compareSubscripts(entries[i].subscript, subscript);
            if( cmp == 0 )
            {
                result = entries[i];
                return true;
            }
            if( cmp > 0 )
                return false;  // past where it would be in sorted order
        }

        curBlock = blockContPtr(block);
    }
    return false;
}

void GlobalStore::insertInChain(quint32 headBlock, const NodeEntry& entry)
{
    // Insert or update a node in the chain; creates continuation blocks as needed.

    quint32 curBlock = headBlock;
    quint32 prevBlock = 0;

    while( curBlock != 0 )
    {
        // Find the correct block and position for sorted insertion.
        QByteArray block = readBlock(curBlock);
        QList<NodeEntry> entries = parseEntries(block);
        quint32 contPtr = blockContPtr(block);
        quint8 btype = blockType(block);

        int insertPos = -1;
        bool found = false;
        for( int i = 0; i < entries.size(); i++ )
        {
            int cmp = compareSubscripts(entries[i].subscript, entry.subscript);
            if( cmp == 0 )
            {
                // existing entry
                entries[i] = entry;
                QByteArray newBlock = serializeEntries(entries, btype, contPtr);
                writeBlock(curBlock, newBlock);
                return;
            }
            if( cmp > 0 )
            {
                insertPos = i;
                found = true;
                break;
            }
        }

        if( found ) // if the entry already exists, update it.
        {
            entries.insert(insertPos, entry);

            int totalSize = BlockHeaderSize;
            for( int i = 0; i < entries.size(); i++ )
                totalSize += entries[i].byteSize();

            if( totalSize <= d_blockSize - 4 )
            {
                // fits in current block
                QByteArray newBlock = serializeEntries(entries, btype, contPtr);
                writeBlock(curBlock, newBlock);
                return;
            }else
            {
                // create a continuation block; keep first half in current block, overflow to new block
                int half = entries.size() / 2;
                QList<NodeEntry> left = entries.mid(0, half);
                QList<NodeEntry> right = entries.mid(half);

                quint32 newBlockId = allocBlock();
                QByteArray newRightBlock = serializeEntries(right, btype, contPtr);
                writeBlock(newBlockId, newRightBlock);

                QByteArray newLeftBlock = serializeEntries(left, btype, newBlockId);
                writeBlock(curBlock, newLeftBlock);
                return;
            }
        }

        if( contPtr == 0 )
        {
            // append to this block if it fits
            entries.append(entry);
            int totalSize = BlockHeaderSize;
            for( int i = 0; i < entries.size(); i++ )
                totalSize += entries[i].byteSize();

            if( totalSize <= d_blockSize - 4 )
            {
                QByteArray newBlock = serializeEntries(entries, btype, 0);
                writeBlock(curBlock, newBlock);
                return;
            }else
            {
                // create continuation block
                int half = entries.size() / 2;
                QList<NodeEntry> left = entries.mid(0, half);
                QList<NodeEntry> right = entries.mid(half);

                quint32 newBlockId = allocBlock();
                QByteArray newRightBlock = serializeEntries(right, btype, 0);
                writeBlock(newBlockId, newRightBlock);

                QByteArray newLeftBlock = serializeEntries(left, btype, newBlockId);
                writeBlock(curBlock, newLeftBlock);
                return;
            }
        }

        prevBlock = curBlock;
        curBlock = contPtr;
    }
}

quint32 GlobalStore::removeFromChain(quint32 headBlock, const QByteArray& subscript)
{
    // remove a node from the chain; returns its down pointer or 0
    quint32 curBlock = headBlock;
    quint32 prevBlock = 0;

    while( curBlock != 0 )
    {
        QByteArray block = readBlock(curBlock);
        QList<NodeEntry> entries = parseEntries(block);
        quint32 contPtr = blockContPtr(block);
        quint8 btype = blockType(block);

        for( int i = 0; i < entries.size(); i++ )
        {
            int cmp = compareSubscripts(entries[i].subscript, subscript);
            if( cmp == 0 )
            {
                quint32 downPtr = entries[i].downPtr;
                entries.removeAt(i);

                if( entries.isEmpty() && prevBlock != 0 )
                {
                    // block is now empty; unlink it from chain
                    QByteArray prevData = readBlock(prevBlock);
                    setBlockContPtr(prevData, contPtr);
                    writeBlock(prevBlock, prevData);
                    freeBlock(curBlock);
                }else if( entries.isEmpty() && prevBlock == 0 )
                {
                    // head block is now empty but we keep it as head
                    QByteArray newBlock = serializeEntries(entries, btype, contPtr);
                    writeBlock(curBlock, newBlock);
                }else
                {
                    QByteArray newBlock = serializeEntries(entries, btype, contPtr);
                    writeBlock(curBlock, newBlock);
                }
                return downPtr;
            }
            if( cmp > 0 )
                return 0;  // not found
        }

        prevBlock = curBlock;
        curBlock = contPtr;
    }
    return 0;
}

QByteArray GlobalStore::orderInChain(quint32 headBlock, const QByteArray& after,
                                      int direction) const
{
    // find the next/previous subscript after 'after' in the chain.
    if( direction >= 0 )
    {
        // forward
        quint32 curBlock = headBlock;
        while( curBlock != 0 )
        {
            QByteArray block = readBlock(curBlock);
            QList<NodeEntry> entries = parseEntries(block);

            for( int i = 0; i < entries.size(); i++ )
            {
                if( after.isEmpty() )
                    return entries[i].subscript;

                int cmp = compareSubscripts(entries[i].subscript, after);
                if( cmp > 0 )
                    return entries[i].subscript;
            }

            curBlock = blockContPtr(block);
        }
        return QByteArray();
    }else
    {
        // reverse
        QByteArray result;
        quint32 curBlock = headBlock;
        while( curBlock != 0 )
        {
            QByteArray block = readBlock(curBlock);
            QList<NodeEntry> entries = parseEntries(block);

            for( int i = 0; i < entries.size(); i++ )
            {
                if( after.isEmpty() )
                    result = entries[i].subscript;  // keep updating to get last
                else
                {
                    int cmp = compareSubscripts(entries[i].subscript, after);
                    if( cmp < 0 )
                        result = entries[i].subscript;
                }
            }

            curBlock = blockContPtr(block);
        }
        return result;
    }
}

bool GlobalStore::chainHasNodes(quint32 headBlock) const
{
    quint32 curBlock = headBlock;
    while( curBlock != 0 )
    {
        QByteArray block = readBlock(curBlock);
        quint16 used = blockUsedBytes(block);
        if( used > BlockHeaderSize )
            return true;
        curBlock = blockContPtr(block);
    }
    return false;
}

quint32 GlobalStore::findLevel(quint32 dirHeadBlock, const QByteArray& global,
                                const QList<QByteArray>& subs, int depth) const
{
    // multi-level search by follow down pointers, [MGI75] 3.3.1

    // find the global's first-level head block from the directory
    NodeEntry dirEntry;
    if( !findInChain(dirHeadBlock, global, dirEntry) )
        return 0;
    if( !(dirEntry.type & NodePointer) )
        return 0;

    quint32 curHead = dirEntry.downPtr;

    // then follow down pointers for subs[0..depth-2]
    for( int i = 0; i < depth; i++ )
    {
        NodeEntry entry;
        if( !findInChain(curHead, subs[i], entry) )
            return 0;
        if( !(entry.type & NodePointer) )
            return 0;
        curHead = entry.downPtr;
    }

    return curHead;
}

quint32 GlobalStore::ensurePath(quint32 dirHeadBlock, const QByteArray& global, const QList<QByteArray>& subs, int depth)
{
    // make sure a path of down pointers exists for subs[0..depth-1], creating intermediate nodes as needed

    NodeEntry dirEntry;
    if( !findInChain(dirHeadBlock, global, dirEntry) )
    {
        // not found, create the global directory entry
        quint32 firstLevel = allocBlock();
        dirEntry.type = NodePointer;
        dirEntry.subscript = global;
        dirEntry.downPtr = firstLevel;
        insertInChain(dirHeadBlock, dirEntry);
    }else if( !(dirEntry.type & NodePointer) )
    {
        // fund, but has no down pointer
        quint32 firstLevel = allocBlock();
        dirEntry.type = (quint8)(dirEntry.type | NodePointer);
        dirEntry.downPtr = firstLevel;
        insertInChain(dirHeadBlock, dirEntry);
    }

    quint32 curHead = dirEntry.downPtr;

    // follow/create path
    for( int i = 0; i < depth; i++ )
    {
        NodeEntry entry;
        if( !findInChain(curHead, subs[i], entry) )
        {
            quint32 childHead = allocBlock();
            entry.type = NodePointer;
            entry.subscript = subs[i];
            entry.downPtr = childHead;
            insertInChain(curHead, entry);
            curHead = childHead;
        }else if( !(entry.type & NodePointer) )
        {
            // node exists with value but no children
            quint32 childHead = allocBlock();
            entry.type = (quint8)(entry.type | NodePointer);
            entry.downPtr = childHead;
            insertInChain(curHead, entry);
            curHead = childHead;
        }else
            curHead = entry.downPtr;
    }

    return curHead;
}

quint32 GlobalStore::findGlobalHeadBlock(const QByteArray& global) const
{
    NodeEntry entry;
    if( findInChain(d_header.globalDirBlock, global, entry) )
    {
        if( entry.type & NodePointer )
            return entry.downPtr;
    }
    return 0;
}

quint32 GlobalStore::getOrCreateGlobalEntry(const QByteArray& global)
{
    NodeEntry entry;
    if( findInChain(d_header.globalDirBlock, global, entry) )
    {
        if( entry.type & NodePointer )
            return entry.downPtr;
        // value but no children
        quint32 headBlock = allocBlock();
        entry.type = (quint8)(entry.type | NodePointer);
        entry.downPtr = headBlock;
        insertInChain(d_header.globalDirBlock, entry);
        return headBlock;
    }
    // else new global entry
    quint32 headBlock = allocBlock();
    entry.type = NodePointer;
    entry.subscript = global;
    entry.downPtr = headBlock;
    insertInChain(d_header.globalDirBlock, entry);
    return headBlock;
}

void GlobalStore::removeGlobalEntry(const QByteArray& global)
{
    removeFromChain(d_header.globalDirBlock, global);
}

void GlobalStore::killChain(quint32 headBlock)
{
    quint32 curBlock = headBlock;
    while( curBlock != 0 )
    {
        QByteArray block = readBlock(curBlock);
        QList<NodeEntry> entries = parseEntries(block);
        quint32 contPtr = blockContPtr(block);

        // kill children
        for( int i = 0; i < entries.size(); i++ )
        {
            if( entries[i].type & NodePointer )
                killChain(entries[i].downPtr);
        }

        freeBlock(curBlock);
        curBlock = contPtr;
    }
}

void GlobalStore::set(const QByteArray& global, const QList<QByteArray>& subs, const QByteArray& value)
{
    if( !d_isOpen )
        return;

    if( subs.isEmpty() )
    {
        // SET ^NAME = value
        NodeEntry entry;
        if( findInChain(d_header.globalDirBlock, global, entry) )
        {
            entry.type = (quint8)(entry.type | NodeValue);
            entry.value = value;
            insertInChain(d_header.globalDirBlock, entry);
        } else
        {
            entry.type = NodeValue;
            entry.subscript = global;
            entry.value = value;
            insertInChain(d_header.globalDirBlock, entry);
        }
        return;
    }

    // SET ^NAME(sub1,...,subN) = value
    quint32 targetLevel;
    if( subs.size() == 1 )
        targetLevel = getOrCreateGlobalEntry(global);
    else
    {
        QList<QByteArray> pathSubs = subs.mid(0, subs.size() - 1);
        targetLevel = ensurePath(d_header.globalDirBlock, global,
                                  pathSubs, pathSubs.size());
    }

    QByteArray lastSub = subs.last();
    NodeEntry entry;
    if( findInChain(targetLevel, lastSub, entry) )
    {
        entry.type = (quint8)(entry.type | NodeValue);
        entry.value = value;
        insertInChain(targetLevel, entry);
    }else
    {
        entry.type = NodeValue;
        entry.subscript = lastSub;
        entry.value = value;
        insertInChain(targetLevel, entry);
    }
}

QByteArray GlobalStore::get(const QByteArray& global,
                             const QList<QByteArray>& subs) const
{
    if( !d_isOpen )
        return QByteArray();

    if( subs.isEmpty() )
    {
        // GET ^NAME
        NodeEntry entry;
        if( findInChain(d_header.globalDirBlock, global, entry) )
        {
            if( entry.type & NodeValue )
                return entry.value;
        }
        return QByteArray();
    }

    // GET ^NAME(sub1,...,subN)
    NodeEntry dirEntry;
    if( !findInChain(d_header.globalDirBlock, global, dirEntry) )
        return QByteArray();
    if( !(dirEntry.type & NodePointer) )
        return QByteArray();

    quint32 curHead = dirEntry.downPtr;

    for( int i = 0; i < subs.size() - 1; i++ )
    {
        NodeEntry entry;
        if( !findInChain(curHead, subs[i], entry) )
            return QByteArray();
        if( !(entry.type & NodePointer) )
            return QByteArray();
        curHead = entry.downPtr;
    }

    // last subscript at target level
    NodeEntry entry;
    if( findInChain(curHead, subs.last(), entry) )
    {
        if( entry.type & NodeValue )
            return entry.value;
    }
    return QByteArray();
}

int GlobalStore::data(const QByteArray& global,
                       const QList<QByteArray>& subs) const
{
    /* returns codes:
        0  = node does not exist
        1  = node exists with value, no children
        10 = node exists with children, no value
        11 = node exists with value and children */

    if( !d_isOpen )
        return 0;

    if( subs.isEmpty() )
    {
        // $DATA(^NAME)
        NodeEntry entry;
        if( !findInChain(d_header.globalDirBlock, global, entry) )
            return 0;

        int result = 0;
        if( entry.type & NodeValue )
            result += 1;
        if( (entry.type & NodePointer) && chainHasNodes(entry.downPtr) )
            result += 10;
        return result;
    }

    // $DATA(^NAME(sub1,...,subN))
    NodeEntry dirEntry;
    if( !findInChain(d_header.globalDirBlock, global, dirEntry) )
        return 0;
    if( !(dirEntry.type & NodePointer) )
        return 0;

    quint32 curHead = dirEntry.downPtr;

    for( int i = 0; i < subs.size() - 1; i++ )
    {
        NodeEntry entry;
        if( !findInChain(curHead, subs[i], entry) )
            return 0;
        if( !(entry.type & NodePointer) )
            return 0;
        curHead = entry.downPtr;
    }

    NodeEntry entry;
    if( !findInChain(curHead, subs.last(), entry) )
        return 0;

    int result = 0;
    if( entry.type & NodeValue )
        result += 1;
    if( (entry.type & NodePointer) && chainHasNodes(entry.downPtr) )
        result += 10;
    return result;
}

QByteArray GlobalStore::order(const QByteArray& global, const QList<QByteArray>& subs,
                               const QByteArray& startAfter, int direction) const
{
    if( !d_isOpen )
        return QByteArray();

    // $ORDER(^NAME(sub1,...,subN-1,startAfter), direction)
    if( subs.isEmpty() )
    {
        // at root level
        NodeEntry dirEntry;
        if( !findInChain(d_header.globalDirBlock, global, dirEntry) )
            return QByteArray();
        if( !(dirEntry.type & NodePointer) )
            return QByteArray();
        return orderInChain(dirEntry.downPtr, startAfter, direction); // the next subscript at the level
    }

    // else navigate to the parent level
    NodeEntry dirEntry;
    if( !findInChain(d_header.globalDirBlock, global, dirEntry) )
        return QByteArray();
    if( !(dirEntry.type & NodePointer) )
        return QByteArray();

    quint32 curHead = dirEntry.downPtr;

    for( int i = 0; i < subs.size(); i++ )
    {
        NodeEntry entry;
        if( !findInChain(curHead, subs[i], entry) )
            return QByteArray();
        if( !(entry.type & NodePointer) )
            return QByteArray();
        curHead = entry.downPtr;
    }

    return orderInChain(curHead, startAfter, direction);
}

void GlobalStore::kill(const QByteArray& global, const QList<QByteArray>& subs)
{
    if( !d_isOpen )
        return;

    if( subs.isEmpty() )
    {
        // root level
        killAll(global);
        return;
    }

    // else find the node and remove it plus all its descendants
    NodeEntry dirEntry;
    if( !findInChain(d_header.globalDirBlock, global, dirEntry) )
        return;
    if( !(dirEntry.type & NodePointer) )
        return;

    quint32 curHead = dirEntry.downPtr;

    for( int i = 0; i < subs.size() - 1; i++ )
    {
        NodeEntry entry;
        if( !findInChain(curHead, subs[i], entry) )
            return;
        if( !(entry.type & NodePointer) )
            return;
        curHead = entry.downPtr;
    }

    // last subscript on its level
    quint32 downPtr = removeFromChain(curHead, subs.last());

    if( downPtr != 0 )
        killChain(downPtr);
}

void GlobalStore::killAll(const QByteArray& global)
{
    if( !d_isOpen )
        return;

    NodeEntry entry;
    if( !findInChain(d_header.globalDirBlock, global, entry) )
        return;

    // free all level blocks
    if( entry.type & NodePointer )
        killChain(entry.downPtr);

    removeFromChain(d_header.globalDirBlock, global);
}

QByteArray GlobalStore::nextGlobal(const QByteArray& after) const
{
    if( !d_isOpen )
        return QByteArray();

    return orderInChain(d_header.globalDirBlock, after, 1);
}
