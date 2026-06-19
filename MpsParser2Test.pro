QT += core
QT -= gui

TARGET = MpsParser2Test
CONFIG += console
CONFIG -= app_bundle

INCLUDEPATH += . ..

SOURCES += \
    MpsParserTest.cpp \
    MpsLexer.cpp \
    MpsToken.cpp \
    MpsParser.cpp \
    MpsParser2.cpp \
    MpsAst.cpp \
    MpsTokenType.cpp

HEADERS += \
    MpsLexer.h \
    MpsToken.h \
    MpsParser.h \
    MpsParser2.h \
    MpsAst.h \
    MpsTokenType.h
