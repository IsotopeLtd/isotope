import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormGenerator extends StatefulWidget {
  final String form;
  final ValueChanged<Map> onChanged;
  final Map initValue;

  FormGenerator({@required this.form, @required this.onChanged, this.initValue});

  @override
  _FormGeneratorState createState() => _FormGeneratorState(json.decode(form));
}

class _FormGeneratorState extends State<FormGenerator> {
  final dynamic formItems;
  final Map<String, dynamic> formResults = {};

  Map<String, dynamic> radioValueMap = {};
  Map<String, String> dropDownMap = {};
  Map<String, String> _datevalueMap = {};
  Map<String, bool> switchValueMap = {};

  Map _initValue;
  _FormGeneratorState(this.formItems);

  @override
  void initState() {
    _initValue = widget.initValue;
    print(_initValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(30),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildForm(),
      ),
    );
  }

  void _handleChanged() {
    widget.onChanged(formResults);
  }

  void _updateSwitchValue(dynamic item, bool value) {
    setState(() {
      switchValueMap[item] = value;
    });
  }

  List<Widget> _buildForm() {
    List<Widget> listWidget = new List<Widget>();

    for (var item in formItems) {
      if (item['type'] == 'text' ||
          item['type'] == 'integer' ||
          item['type'] == "password" ||
          item['type'] == "multiline") {
        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              initialValue: _initValue != null ? _initValue[item["title"]] : null,
              autofocus: false,
              onChanged: (String value) {
                formResults[item["title"]] = value;
                _handleChanged();
              },
              inputFormatters: item['type'] == 'integer'
                  ? [WhitelistingTextInputFormatter(RegExp('[0-9]'))]
                  : null,
              keyboardType: item['type'] == 'integer' ? TextInputType.number : null,
              validator: (String value) {
                if (item['required'] == 'no') {
                  return null;
                }
                if (value.isEmpty) {
                  return '${item['title']} cannot be empty';
                }
                return null;
              },
              maxLines: item['type'] == "multiline" ? 10 : 1,
              obscureText: item['type'] == "password" ? true : false,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: item['label'],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
              ),
            ),
          ),
        );
      }

      if (item['type'] == 'select') {
        var newlist = List<String>.from(item['items']);

        listWidget.add(Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0)
              ),
            ),
            hint: Text('Select ${item['title']}'),
            validator: (String value) {
              if (item['required'] == 'no') {
                return null;
              }
              if (value == null) {
                return '${item['title']} cannot be empty';
              }
              return null;
            },
            value: dropDownMap[item["title"]],
            isExpanded: true,
            style: Theme.of(context).textTheme.subtitle1,
            onChanged: (String newValue) {
              setState(() {
                dropDownMap[item["title"]] = newValue;
                formResults[item["title"]] = newValue.trim();
              });
              _handleChanged();
            },
            items: newlist.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ));
      }

      if (item['type'] == 'date') {
        Future _selectDate() async {
          DateTime picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1880),
            lastDate: DateTime(2021),
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light(),
                child: child,
              );
            },
          );
          if (picked != null) {
            setState(() => _datevalueMap[item["title"]] = picked.toString().substring(0, 10));
          }
        }

        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              initialValue: _initValue != null ? _initValue[item["title"]] : null,
              autofocus: false,
              readOnly: true,
              controller: TextEditingController(text: _datevalueMap[item["title"]]),
              validator: (String value) {
                if (value.isEmpty) {
                  return '${item['title']} cannot be empty';
                }
                return null;
              },
              onChanged: (String value) {
                _handleChanged();
              },
              onTap: () async {
                await _selectDate();
                formResults[item["title"]] = _datevalueMap[item["title"]];
                _handleChanged();
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: item["label"],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                ),
              ),
            )
          ),
        );
      }

      if (item['type'] == 'radio') {
        radioValueMap["${item["title"]}"] =
            radioValueMap["${item["title"]}"] == null
                ? 'lost'
                : radioValueMap["${item["title"]}"];

        listWidget.add(
          new Container(
            margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: new Text(
              item['label'],
              style: new TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16.0
              )
            )
          )
        );

        for (var i = 0; i < item['items'].length; i++) {
          listWidget.add(
            new Row(
              children: <Widget>[
                new Expanded(child: new Text(item['items'][i])),
                new Radio<dynamic>(
                    // hoverColor: Colors.red,
                    value: item['items'][i],
                    groupValue: radioValueMap["${item["title"]}"],
                    onChanged: (dynamic value) {
                      setState(() {
                        radioValueMap["${item["title"]}"] = value;
                      });
                      formResults[item["title"]] = value;
                      _handleChanged();
                    })
              ],
            ),
          );
        }
      }

      if (item['type'] == 'switch') {
        if (switchValueMap["${item["title"]}"] == null) {
          setState(() {
            switchValueMap["${item["title"]}"] = false;
          });
        }
        listWidget.add(
          Row(
            children: <Widget>[
              new Expanded(child: new Text(item["label"])),
              Switch(
                value: switchValueMap["${item["title"]}"],
                onChanged: (bool value) {
                  _updateSwitchValue(item["title"], value);
                  formResults[item["title"]] = value;
                  _handleChanged();
                }
              ),
            ],
          )
        );
      }
    }
    return listWidget;
  }
}
