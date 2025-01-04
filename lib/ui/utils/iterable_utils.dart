bool isEqualsList(List<dynamic> list1, List<dynamic> list2) {
  if (list1.length != list2.length) {
    return false;
  }

  if (list1 == list2) {
    return true;
  }

  for (var i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }

  return true;
}
