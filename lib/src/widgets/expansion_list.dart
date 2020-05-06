import 'package:flutter/material.dart';

class ExpansionList<T> extends StatefulWidget {
  final List<T> items;
  final String title;
  final Function(T) onItemSelected;
  final bool smallVersion;
  final double fieldHeight;
  final double smallFieldHeight;
  final EdgeInsets fieldPadding;
  final BoxDecoration fieldDecoration;

  ExpansionList({
    Key key,
    this.items,
    this.title,
    @required this.onItemSelected,
    this.smallVersion = false,
    this.fieldHeight,
    this.smallFieldHeight,
    this.fieldPadding,
    this.fieldDecoration,
  }) : super(key: key);

  _ExpansionListState createState() => _ExpansionListState();
}

class _ExpansionListState extends State<ExpansionList> {
  double startingHeight;
  double expandedHeight;
  bool expanded = false;
  String selectedValue;

  @override
  void initState() {
    super.initState();
    startingHeight = widget.fieldHeight;
    selectedValue = widget.title;
    _calculateExpandedHeight();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: widget.fieldPadding,
      duration: const Duration(milliseconds: 180),
      height: expanded
        ? expandedHeight
        : widget.smallVersion
          ? widget.smallFieldHeight
          : startingHeight,
      decoration: widget.fieldDecoration.copyWith(
        boxShadow: expanded
          ? [BoxShadow(blurRadius: 10, color: Colors.grey[300])]
          : null,
      ),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          ExpansionListItem(
            title: selectedValue,
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            showArrow: true,
            smallVersion: widget.smallVersion,
          ),
          Container(
            height: 2,
            color: Colors.grey[300],
          ),
          ..._getDropdownListItems()
        ],
      ),
    );
  }

  List<Widget> _getDropdownListItems() {
    return widget.items
      .map((item) => ExpansionListItem(
        smallVersion: widget.smallVersion,
        fieldHeight: widget.fieldHeight,
        smallFieldHeight: widget.smallFieldHeight,
        title: item.toString(),
        onTap: () {
          setState(() {
            expanded = !expanded;
            selectedValue = item.toString();
          });

          widget.onItemSelected(item);
        }))
        .toList();
  }

  void _calculateExpandedHeight() {
    expandedHeight = 2 +
      (widget.smallVersion
        ? widget.smallFieldHeight
        : widget.fieldHeight) +
          (widget.items.length *
            (widget.smallVersion
              ? widget.smallFieldHeight
              : widget.fieldHeight));
  }
}

class ExpansionListItem extends StatelessWidget {
  final Function onTap;
  final String title;
  final bool showArrow;
  final bool smallVersion;
  final double fieldHeight;
  final double smallFieldHeight;

  const ExpansionListItem({
    Key key,
    this.onTap,
    this.title,
    this.showArrow = false,
    this.smallVersion = false,
    this.fieldHeight,
    this.smallFieldHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: smallVersion
          ? smallFieldHeight
          : fieldHeight,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                title ?? '',
                style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontSize: smallVersion ? 12 : 15),
              ),
            ),
            showArrow
                ? Icon(
                  Icons.arrow_drop_down,
                    color: Colors.grey[700],
                    size: 20,
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
