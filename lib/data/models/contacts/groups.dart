import 'package:scoped_model/scoped_model.dart';
import '../../classes/unify/contact_group.dart';
import '../../repositories/contacts/groups.dart';
import '../../classes/contacts/contact_row.dart';
import 'package:flutter/foundation.dart';
import '../auth_model.dart';
import 'package:flutter/material.dart';
import '../../classes/app/paging.dart';
import '../../classes/app/sort.dart';

class ContactGroupModel extends Model {
  final AuthModel auth;

  ContactGroupModel({@required this.auth});

  List<ContactGroup> _groups;

  List<ContactGroup> get groups => _groups ?? [];

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  bool _fetching = false;

  bool get fetching => _fetching;

  String _id = "";

  String get id => _id;

  void setGroupID(String value) {
    _id = value;
    notifyListeners();
  }

  Future loadContactGroups({bool force = false}) async {
    _isLoaded = false;
    _fetching = true;
    notifyListeners();

    if (!_fetching) {
      var _response = await ContactGroupRepository().getContactGroups(auth);
      if (force) {
        _groups.clear();
        notifyListeners();
      }

      List<dynamic> _result = _response?.result;

      var _results = _result
          ?.map((e) => e == null
              ? null
              : ContactGroup.fromJson(e as Map<String, dynamic>))
          ?.toList();

      _groups = _results;
      _fetching = false;
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future editContactGroup({
    @required ContactGroup model,
    bool isNew = true,
  }) async {
    _isLoaded = false;
    _fetching = true;
    notifyListeners();

    bool _valid = true;
    if (isNew) {
      _valid = await ContactGroupRepository()
          .addContactGroup(auth, name: model?.name);
    } else {
      _valid = await ContactGroupRepository()
          .editContactGroup(auth, name: model?.name, id: model?.id);
    }

    _groups.clear();
    notifyListeners();

    loadContactGroups(force: true);

    _isLoaded = true;
    _fetching = false;
    notifyListeners();
  }

  Future deleteContactGroup({@required String id}) async {
    _isLoaded = false;
    _fetching = true;
    notifyListeners();

    _groups.clear();
    notifyListeners();

    bool _valid =
        await ContactGroupRepository().deleteContactGroup(auth, id: id);

    loadContactGroups(force: true);

    _isLoaded = true;
    _fetching = false;
    notifyListeners();
  }

  // -- Contacts For Group --

  // -- Search --
  String _searchValue = "";
  bool _isSearching = false;

  String get searchValue => _searchValue;
  bool get isSearching => _isSearching;

  void searchPressed() {
    _isSearching = !_isSearching;
    notifyListeners();
  }

  void searchChanged(String value) {
    _searchValue = value;

    print("Searching... $value");

    // -- Local Search --
    List<ContactRow> _results = [];

    if (_contacts != null && _contacts.isNotEmpty) {
      for (var _item in _contacts) {
        if (_item.matchesSearch(value)) {
          _results.add(_item);
        }
      }
      _filtered = _results;
    }

    notifyListeners();
  }

  // -- Sort --
  Sort _sort = Sort(
    initialized: true,
    ascending: true,
    field: ContactFields.last_name,
    fields: [
      ContactFields.last_name,
      ContactFields.first_name,
    ],
  );

  Sort get sort => _sort;

  void sortChanged(Sort value) {
    _sort = value;
    notifyListeners();
  }

  void _sortList(String field, bool ascending) {
    _contacts?.sort((a, b) => a.compareTo(b, field, ascending));
    notifyListeners();
  }

  List<ContactRow> _contacts, _filtered;

  List<ContactRow> get contacts {
    // -- Searching --
    if (_isSearching) {
      if (_filtered == null) {
        _filtered = _contacts;
      }
      _sortList(_sort?.field, _sort?.ascending);
      return _filtered;
    }

    if (_contacts == null || !_isLoaded) {
      _loadList();
    }
    _sortList(_sort?.field, _sort?.ascending);
    return _contacts;
  }

  Paging _paging = Paging(rows: 100, page: 1);

  bool _lastPage = false;

  bool get lastPage => _lastPage;

  Future refresh() async {
    print("Refreshing List...");
    _paging = Paging(rows: 100, page: 1);
    await _loadList();
  }

  Future loadData(String id) async {
    setGroupID(id);
    await _loadList();
  }

  Future _loadList({bool nextPage = false}) async {
    _isLoaded = false;
    notifyListeners();

    if (!_fetching) {
      _fetching = true;
      var _items = await ContactGroupRepository()
          .getContactsFromGroup(auth, id: _id, paging: _paging);

      List<dynamic> _result = _items?.result;

      if (_result?.isEmpty ?? true) {
        _lastPage = true;
        _paging.page -= 1;
      } else {
        var _results = _result
            ?.map((e) => e == null
                ? null
                : ContactRow.fromJson(e as Map<String, dynamic>))
            ?.toList();

        if (nextPage) {
          _contacts.addAll(_results);
        } else {
          _contacts = _results;
        }

        _lastPage = false;
      }

      _isLoaded = true;
      _fetching = false;
    }

    notifyListeners();
  }

  void fetchNext() {
    if (!_lastPage) {
      print("Fetching Next Page...");
      _paging.page += 1;
      _loadList(nextPage: true);
    }
  }
}