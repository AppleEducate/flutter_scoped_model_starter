import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../data/classes/contacts/contact_details.dart';
import '../../data/classes/contacts/contact_row.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/sort_model.dart';
import '../../ui/app/app_bottom_bar.dart';
import '../../ui/app/app_drawer.dart';
import '../../ui/app/app_search_bar.dart';
import 'edit.dart';
import 'list.dart';
import '../app/app_sort_button.dart';
import '../../data/classes/app/sort.dart';

class ContactScreen extends StatelessWidget {
  final ContactModel model;

  ContactScreen({@required this.model});
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactModel>(
      model: model,
      child: new ScopedModel<SortModel>(
        model: SortModel(),
        child: _ContactScreen(),
      ),
    );
  }
}

class _ContactScreen extends StatefulWidget {
  @override
  __ContactScreenState createState() => __ContactScreenState();
}

class __ContactScreenState extends State<_ContactScreen> {
  bool _isDisposed = false;
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool _isSearching = false;
  // bool _sortASC = true;
  // String _sortField = ContactFields.last_name;
  RefreshController _refreshController;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void showInSnackBar(Widget child) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: child));
  }

  @override
  void initState() {
    _refreshController = new RefreshController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _model = ScopedModel.of<ContactModel>(context, rebuildOnChange: true);
    final _sort = ScopedModel.of<SortModel>(context, rebuildOnChange: true);
    final _auth = ScopedModel.of<AuthModel>(context, rebuildOnChange: true);
    if (!_sort.ready) {
      _sort.sortAscending = true;
      _sort.setDefaults(
        field: ContactFields.last_name,
        fields: [
          ContactFields.first_name,
          ContactFields.last_name,
          // ContactFields.last_activity,
        ],
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AppSearchBar(
          name: "Contact" + "s",
          isSearching: _isSearching,
          onSearchChanged: (String value) {
            _model.search(value);
          },
        ),
        actions: <Widget>[
          AppSearchButton(
            isSearching: _isSearching,
            onSearchPressed: () {
              if (!_isDisposed)
                setState(() {
                  _isSearching = !_isSearching;
                });
              if (_isSearching) {
                _model.startSearching();
              } else {
                _model.stopSearching(context);
              }
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: FutureBuilder(
          // future: _model.loadItems(context),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (_model.isLoaded == false || _auth.userChanged) {
              _model.loadItems(context);
              _model.loaded = true;
              return Center(child: CircularProgressIndicator());
            }
            // if (_sortField.isEmpty) {
            //   _sortField = _sort.sortField;
            // }
            // _sort.sortField = _sortField;
            // _sort.sortAscending = _sortASC;
            // _model.sort(_sortField, _sortASC);
            return new SmartRefresher(
                enablePullDown: true,
                enablePullUp: (_model?.items?.length ?? 0) > 10,
                controller: _refreshController,
                onRefresh: (up) {
                  if (up) {
                    _model.refresh(context).then((_) {
                      _refreshController.sendBack(true, RefreshStatus.idle);
                      if (!_isDisposed) setState(() {});
                    });
                  } else {
                    _model.nextPage(context).then((_) {
                      if (_model?.lastPage == true) {
                        print("No Items Found on Next Page");
                        showInSnackBar(Text("No More Items"));
                      } else {
                        _refreshController.scrollTo(
                            _refreshController.scrollController.offset + 100.0);
                      }
                      _refreshController.sendBack(false, RefreshStatus.idle);
                      if (!_isDisposed) setState(() {});
                    });
                  }
                },
                // onOffsetChange: _onOffsetCallback,
                child: buildList(
                  model: _model,
                  isSearching: _isSearching,
                  auth: _auth,
                ));
          },
        ),
      ),
      // body: ContactList(model: _model, isSearching: _isSearching),
      bottomNavigationBar: AppBottomBarStateless(
        buttons: [
          new ScopedModelDescendant<ContactModel>(
              builder: (context, child, model) => AppSortButton(
                    sort: model.sorting,
                    sortChanged: (Sort value) {
                      setState(() {
                        model.sortChanged(value);
                      });
                    },
                  )),
          IconButton(
            tooltip: "Refresh",
            icon: Icon(Icons.refresh),
            onPressed: () {
              _refreshController.requestRefresh(true);
              _model.refresh(context).then((_) {
                _refreshController.sendBack(true, RefreshStatus.idle);
                if (!_isDisposed) setState(() {});
              });
            },
          ),
          IconButton(
            tooltip: "Import Contacts",
            icon: Icon(Icons.import_contacts),
            onPressed: () =>
                Navigator.pushNamed(context, "/import").then((value) {
                  if (value != null) {
                    List<Contact> _items = value ?? [];
                    // Add Items
                    showInSnackBar(Text("Importing Contacts..."));
                    var _list = <ContactDetails>[];
                    for (var _item in _items) {
                      // ContactObject _contactObject = ContactObject(
                      //   firstName: _item?.givenName,
                      //   lastName: _item?.familyName,
                      // );
                      // _model.addItem(_contactObject);
                      // print("Adding... ${_contactObject?.firstName}");
                      _list.add(ContactDetails.fromPhoneContact(_item));
                    }
                    _model?.importItems(context, items: _list);
                  }
                }),
          ),
          IconButton(
            tooltip: "Contact Tasks",
            icon: Icon(Icons.event),
            onPressed: () {
              Navigator.pushNamed(context, "/contact_tasks");
            },
          ),
          IconButton(
            tooltip: "Contact Groups",
            icon: Icon(Icons.group),
            onPressed: () {
              Navigator.pushNamed(context, "/contact_groups");
            },
          ),
        ],
        // onChangeSortOrder: (bool value) {
        //   if (!_isDisposed)
        //     setState(() {
        //       _sort.sortAscending = value;
        //       _sortASC = value;
        //       _model.sort(_sortField, _sortASC);
        //     });
        // },
        // onSelectedSortField: (String value) {
        //   if (_sortField.contains(value)) {
        //     if (!_isDisposed)
        //       setState(() {
        //         _sortASC = !_sortASC;
        //         _sort.sortAscending = _sortASC;
        //         _model.sort(_sortField, _sortASC);
        //       });
        //   } else {
        //     if (!_isDisposed)
        //       setState(() {
        //         _sort.sortField = value;
        //         _sortField = value;
        //         _model.sort(_sortField, _sortASC);
        //       });
        //   }
        // },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: "Contact Add",
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ContactItemEdit(
                      model: _model,
                      auth: _auth,
                    ),
                fullscreenDialog: true),
          ).then((value) {
            if (value != null) {
              ContactDetails _item = value;
              _model.addItem(context, item: _item);
              // _model.sort(_sortField, _sortASC);
            }
          });
        },
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'New Item',
      ),
    );
  }
}
