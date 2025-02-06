import 'package:flutter/material.dart';

abstract class SonaIcons {
  static const String _fontFamily = 'SonaIcons';

  static final IconData messageCard = _ofCharacter('A');
  static final IconData padlock = _ofCharacter('B');
  static final IconData eye = _ofCharacter('C');
  static final IconData eyeOff = _ofCharacter('a');
  static final IconData menu = _ofCharacter('D');
  static final IconData user = _ofCharacter('E');
  static final IconData campaing = _ofCharacter('F');
  static final IconData warning = _ofCharacter('G');
  static final IconData reloadPadlock = _ofCharacter('H');
  static final IconData back = _ofCharacter('I');
  static final IconData hearth = _ofCharacter('K');
  static final IconData message = _ofCharacter('L');
  static final IconData forbidden = _ofCharacter('M');
  static final IconData x = _ofCharacter('N');
  static final IconData trash = _ofCharacter('O');
  static final IconData camera = _ofCharacter('P');
  static final IconData uploadImage = _ofCharacter('Q');
  static final IconData userCircle = _ofCharacter('R');
  static final IconData userCirclePlus = _ofCharacter('S');
  static final IconData penWrite = _ofCharacter('T');
  static final IconData happyFace = _ofCharacter('U');
  static final IconData microphone = _ofCharacter('V');
  static final IconData arrowLeft = _ofCharacter('W');
  static final IconData plusSquare = _ofCharacter('X');
  static final IconData send = _ofCharacter('Y');
  static final IconData like = _ofCharacter('Z');

  static final IconData phone = _ofCharacter('b');
  static final IconData settings = _ofCharacter('c');
  static final IconData likeFill = _ofCharacter('d');
  static final IconData flag = _ofCharacter('e');
  static final IconData chat = _ofCharacter('f');
  static final IconData professional = _ofCharacter('g');
  static final IconData filter = _ofCharacter('h');
  static final IconData search = _ofCharacter('i');
  static final IconData calendar = _ofCharacter('j');
  static final IconData clock = _ofCharacter('k');
  static final IconData emptyUser = _ofCharacter('l');
  static final IconData fillUser = _ofCharacter('m');
  static final IconData fillCamera = _ofCharacter('n');
  static final IconData drop = _ofCharacter('o');

  static IconData _ofCharacter(String character) {
    return IconData(character.codeUnitAt(0), fontFamily: _fontFamily);
  }
}
