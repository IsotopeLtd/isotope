import 'package:flutter/material.dart';
import 'package:isotope/view_models.dart';
import 'package:isotope/src/models/navbar_item_model.dart';

class NavBarItemTabletDesktop extends ViewModelWidget<NavBarItemModel> {
  @override
  Widget build(BuildContext context, NavBarItemModel model) {
    return Text(
      model.title,
      style: TextStyle(fontSize: 18),
    );
  }
}
