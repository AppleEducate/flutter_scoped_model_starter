import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../data/classes/unify/contact_group.dart';
import '../../../data/models/leads/groups.dart';
import '../../../data/models/leads/list.dart';

class EditContactGroup extends StatefulWidget {
  final bool isNew;
  final ContactGroup group;
//  final VoidCallback groupDeleted;
  final LeadGroupModel groupModel;
  EditContactGroup({
    this.isNew,
    this.groupModel,
    this.group,
//    this.groupDeleted,
  });

  @override
  EditContactGroupState createState() {
    return new EditContactGroupState();
  }
}

class EditContactGroupState extends State<EditContactGroup> {
  bool _isDisposed = false;
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameController = TextEditingController(
      text: widget?.group?.name ?? "",
    );
    // setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<LeadGroupModel>(
        model: widget.groupModel,
        child: Scaffold(
          appBar: AppBar(
            title:
                Text(widget.isNew ? "Add Contact Group" : "Edit Contact Group"),
            actions: widget.isNew
                ? null
                : <Widget>[
                    new ScopedModelDescendant<LeadGroupModel>(
                        builder: (context, child, model) => model.fetching
                            ? Container(
                                height: 48.0,
                                child: CircularProgressIndicator(),
                              )
                            : IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: widget.group?.count != 0
                                    ? null
                                    : () async {
                                        await model.deleteContactGroup(
                                            id: widget?.group?.id);
                                        if (model.success)
                                          Navigator.pop(context, false);
                                      },
                              )),
                  ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: TextFormField(
                        autofocus: true,
                        decoration: InputDecoration(labelText: "Group Name"),
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        validator: (val) =>
                            val.isEmpty ? 'Please enter a Group Name' : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new ScopedModelDescendant<LeadGroupModel>(
                            builder: (context, child, model) => model.fetching
                                ? Center(child: CircularProgressIndicator())
                                : RaisedButton(
                                    color: Colors.blue,
                                    child: Text(
                                      widget.isNew ? "Add Group" : "Save Group",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        // -- Save Info --
                                        final _name =
                                            _nameController?.text ?? "";
                                        final ContactGroup _group =
                                            ContactGroup(
                                                id: widget?.group?.id ?? "",
                                                name: _name);
                                        await model.editContactGroup(_group,
                                            isNew: widget.isNew);
                                        Navigator.pop(context, true);
                                      }
                                    },
                                  )),
                      ],
                    ),
                    Container(height: 50.0),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

Future<bool> createGroup(BuildContext context,
    {@required LeadModel model}) async {
  bool _created = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new EditContactGroup(
              isNew: true,
              groupModel: LeadGroupModel(auth: model?.auth),
            ),
        fullscreenDialog: true,
      ));
  return _created; // True = Created
}

Future<bool> editGroup(BuildContext context,
    {@required ContactGroup group, @required LeadModel model}) async {
  bool _edited = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new EditContactGroup(
            groupModel: LeadGroupModel(auth: model?.auth, id: group?.id),
            isNew: false,
            group: group),
        fullscreenDialog: true,
      ));
  return _edited; //True = Edited, False = Deleted
}