import 'package:flutter/material.dart';
import 'package:isotope/registrar.dart';
import 'package:isotope/src/models/dialog_request.dart';
import 'package:isotope/src/models/dialog_response.dart';
import 'package:isotope/src/services/dialog_service.dart';

class DialogManager extends StatefulWidget {
  final Widget child;
  final Registrar serviceManager;
  
  DialogManager({this.serviceManager, this.child});

  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager> {
  DialogService _dialogService;

  @override
  void initState() {
    super.initState();
    _dialogService = widget.serviceManager<DialogService>();
    _dialogService.registerDialogListener(_showDialog);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _showDialog(DialogRequest request) {
    var isConfirmationDialog = request.cancelTitle != null;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.title),
        content: Text(request.description),
        actions: <Widget>[
          if (isConfirmationDialog)
            FlatButton(
              child: Text(request.cancelTitle),
              onPressed: () {
                _dialogService.dialogComplete(DialogResponse(confirmed: false));
              },
            ),
            FlatButton(
              child: Text(request.buttonTitle),
              onPressed: () {
                _dialogService.dialogComplete(DialogResponse(confirmed: true));
              },
            ),
        ],
      )
    );
  }
}
