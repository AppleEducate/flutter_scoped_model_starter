import 'package:flutter/material.dart';
import 'package:contact_picker/contact_picker.dart';

import '../../constants.dart';
import '../../data/classes/general/phone.dart';
import '../../utils/null_or_empty.dart';
import '../../utils/phoneCall.dart';
import '../../utils/sendSMS.dart';

class PhoneTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Phone number;

  PhoneTile({this.label, this.number, this.icon});

  @override
  Widget build(BuildContext context) {
    // var _raw = (number ?? "")
    //     .replaceAll("(", "")
    //     .replaceAll(")", "")
    //     .replaceAll("-", "")
    //     .replaceAll(" ", "")
    //     .trim();
    var _raw = number?.raw();
    if (isNullOrEmpty(_raw)) {
      return ListTile(
        leading: Icon(icon ?? Icons.phone),
        title: Text(
          isNullOrEmpty(label) ? 'Phone Number' : label,
          textScaleFactor: textScaleFactor,
        ),
        subtitle: const Text(
          "No Number Found",
          textScaleFactor: textScaleFactor,
        ),
      );
    }

    return ListTile(
      leading: Icon(icon ?? Icons.phone),
      title: Text(
        label ?? 'Phone Number',
        textScaleFactor: textScaleFactor,
      ),
      subtitle: Text(
        number?.toString(),
        textScaleFactor: textScaleFactor,
      ),
      trailing: IconButton(
        icon: Icon(Icons.message),
        onPressed: () => sendSMS("", [_raw]),
      ),
      onTap: () => makePhoneCall(context, _raw),
    );
  }
}

class PhoneInputTile extends StatefulWidget {
  final String label;
  final Phone number;
  final ValueChanged<Phone> numberChanged;
  final bool showExt;

  PhoneInputTile({
    this.numberChanged,
    this.number,
    this.label,
    this.showExt = false,
  });

  @override
  _PhoneInputTileState createState() => _PhoneInputTileState();
}

class _PhoneInputTileState extends State<PhoneInputTile> {
  TextEditingController _areaCode, _prefix, _number, _ext;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  @override
  void initState() {
    _areaCode = TextEditingController(text: widget?.number?.areaCode ?? "");
    _prefix = TextEditingController(text: widget?.number?.prefix ?? "");
    _number = TextEditingController(text: widget?.number?.number ?? "");
    _ext = TextEditingController(text: widget?.number?.ext ?? "");
    super.initState();
  }

  Phone get phone {
    var _phone = Phone(
      label: widget?.label?.toLowerCase()?.replaceAll("number", "")?.trim() ??
          "number",
      areaCode: _areaCode?.text ?? "",
      prefix: _prefix?.text ?? "",
      number: _number?.text ?? "",
    );
    // if (_phone.raw().isEmpty) return null;
    return _phone;
  }

  void _clear() {
    _areaCode.clear();
    _prefix.clear();
    _number.clear();
    _ext.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Widget searchContacts = IconButton(
        icon: Icon(Icons.search),
        onPressed: () async {
          final ContactPicker _contactPicker = new ContactPicker();
          Contact contact = await _contactPicker.selectContact();
          if (contact != null) {
            var _value = contact?.phoneNumber?.number;
            var _newPhone = Phone.fromString(_value);
            _clear();
            setState(() {
              _areaCode.text = _newPhone?.areaCode;
              _prefix.text = _newPhone?.prefix;
              _number.text = _newPhone?.number;
              _ext.text = _newPhone?.ext;
            });
          }
        });
    if (!_isEditing)
      return ListTile(
        leading: searchContacts,
        title: Text(
          widget?.label ?? "Phone Number",
          style: Theme.of(context).textTheme?.body1,
        ),
        subtitle: phone == null || phone.raw().isEmpty
            ? Text("No Number Added")
            : Text(phone.toString()),
        trailing:
            Icon(phone == null || phone.raw().isEmpty ? Icons.add : Icons.edit),
        onTap: () {
          setState(() {
            _isEditing = !_isEditing;
          });
        },
      );
    return ListTile(
      leading: searchContacts,
      title: Form(
        autovalidate: true,
        key: _formKey,
        child: Row(
          children: <Widget>[
            SizedBox(
                width: 75.0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Area"),
                    controller: _areaCode,
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                  ),
                )),
            SizedBox(
                width: 75.0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Prefix"),
                    controller: _prefix,
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                  ),
                )),
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: "Number"),
                controller: _number,
                maxLength: 4,
                keyboardType: TextInputType.number,
              ),
            )),
            widget.showExt
                ? SizedBox(
                    width: 75.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: "Ext."),
                        controller: _ext,
                        maxLength: 15,
                        keyboardType: TextInputType.number,
                      ),
                    ))
                : Container(),
          ],
        ),
        onChanged: () {
          widget.numberChanged(phone);
        },
      ),
      trailing: Icon(Icons.close),
      onTap: () {
        setState(() {
          _isEditing = !_isEditing;
        });
      },
    );
  }
}
