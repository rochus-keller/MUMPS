QT += core
QT -= gui

TARGET = MpsParserTest
CONFIG += console
CONFIG -= app_bundle

INCLUDEPATH += . ..

SOURCES += \
    MpsParserTest.cpp \
    MpsLexer.cpp \
    MpsToken.cpp \
    MpsParser.cpp \
    MpsTokenType.cpp

HEADERS += \
    MpsLexer.h \
    MpsToken.h \
    MpsParser.h \
    MpsTokenType.h
