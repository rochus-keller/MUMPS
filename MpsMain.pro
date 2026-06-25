QT += core
QT -= gui

TARGET = mumps
CONFIG += console
CONFIG -= app_bundle

INCLUDEPATH += . ..

SOURCES += \
    MpsAst.cpp \
    MpsCollation.cpp \
    MpsInterpreter.cpp \
    MpsMain.cpp \
    MpsLexer.cpp \
    MpsNode.cpp \
    MpsParser.cpp \
    MpsParser2.cpp \
    MpsToken.cpp \
    MpsTokenType.cpp \
    MpsValue.cpp

HEADERS += \
    MpsAst.h \
    MpsCollation.h \
    MpsInterpreter.h \
    MpsLexer.h \
    MpsNode.h \
    MpsParser.h \
    MpsParser2.h \
    MpsToken.h \
    MpsTokenType.h \
    MpsValue.h
