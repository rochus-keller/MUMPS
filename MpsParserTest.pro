QT += core
QT -= gui

TARGET = MpsParserTest
CONFIG += console
CONFIG -= app_bundle

INCLUDEPATH += . ..

SOURCES += \
    MpsAst.cpp \
    MpsCollation.cpp \
    MpsNode.cpp \
    MpsParser2.cpp \
    MpsParserTest.cpp \
    MpsLexer.cpp \
    MpsToken.cpp \
    MpsParser.cpp \
    MpsTokenType.cpp \
    MpsValue.cpp

HEADERS += \
    MpsAst.h \
    MpsCollation.h \
    MpsLexer.h \
    MpsNode.h \
    MpsParser2.h \
    MpsToken.h \
    MpsParser.h \
    MpsTokenType.h \
    MpsValue.h
