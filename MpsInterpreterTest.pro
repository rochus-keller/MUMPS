QT += core
QT -= gui

TARGET = mumps76
CONFIG += console
CONFIG -= app_bundle

INCLUDEPATH += . ..

SOURCES += \
    MpsInterpreterTest.cpp \
    MpsInterpreter.cpp \
    MpsLexer.cpp \
    MpsToken.cpp \
    MpsParser.cpp \
    MpsParser2.cpp \
    MpsAst.cpp \
    MpsTokenType.cpp \
    MpsValue.cpp \
    MpsCollation.cpp \
    MpsNode.cpp

HEADERS += \
    MpsInterpreter.h \
    MpsLexer.h \
    MpsToken.h \
    MpsParser.h \
    MpsParser2.h \
    MpsAst.h \
    MpsTokenType.h \
    MpsValue.h \
    MpsCollation.h \
    MpsNode.h
