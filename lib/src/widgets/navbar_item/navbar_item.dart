import 'package:flutter/material.dart';
import 'package:isotope/registrar.dart';
import 'package:isotope/views.dart';
import 'package:isotope/src/models/navbar_item_model.dart';
import 'package:isotope/src/extensions/hover_extensions.dart';
import 'package:isotope/src/services/navigation_service.dart';
import 'package:isotope/src/widgets/navbar_item/navbar_item_desktop.dart';
import 'package:isotope/src/widgets/navbar_item/navbar_item_mobile.dart';
import 'package:provider/provider.dart';

class NavBarItem extends StatelessWidget {
  final Registrar serviceManager;
  final String title;
  final String navigationPath;
  final IconData icon;

  const NavBarItem(this.serviceManager, this.title, this.navigationPath, {this.icon});

  @override
  Widget build(BuildContext context) {
    var model = NavBarItemModel(
      title: title,
      navigationPath: navigationPath,
      iconData: icon,
    );
    return GestureDetector(
      onTap: () {
        serviceManager<NavigationService>().navigateTo(navigationPath);
      },
      child: Provider.value(
        value: model,
        child: ResponsiveLayout(
          tablet: NavBarItemTabletDesktop(),
          mobile: NavBarItemMobile(),
        ).showCursorOnHover.moveUpOnHover,
      ),
    );
  }
}
