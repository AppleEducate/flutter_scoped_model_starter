import 'package:flutter/foundation.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../classes/app/paging.dart';
import '../../classes/app/sort.dart';
import '../../classes/leads/lead_row.dart';
import '../../repositories/leads/list.dart';
import '../auth_model.dart';

class LeadModel extends Model {
  final AuthModel auth;

  LeadModel({@required this.auth});

  String get title => "Leads";

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
    List<LeadRow> _results = [];

    if (_leads != null && _leads.isNotEmpty) {
      for (var _item in _leads) {
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
    field: LeadFields.last_name,
    fields: [
      LeadFields.last_name,
      LeadFields.first_name,
    ],
  );

  Sort get sort => _sort;

  void sortChanged(Sort value) {
    _sort = value;
    notifyListeners();
  }

  void _sortList(String field, bool ascending) {
    _leads?.sort((a, b) => a.compareTo(b, field, ascending));
    notifyListeners();
  }

  // -- Data --
  bool _isLoaded = false;

  get isLoaded => _isLoaded;

  List<LeadRow> _leads, _filtered;

  List<LeadRow> get leads {
    // -- Searching --
    if (_isSearching) {
      if (_filtered == null) {
        _filtered = _leads;
      }
      _sortList(_sort?.field, _sort?.ascending);
      return _filtered;
    }

    if (_leads == null || !_isLoaded) {
      _loadList();
    }
    _sortList(_sort?.field, _sort?.ascending);
    return _leads;
  }

  Paging _paging = Paging(rows: 100, page: 1);

  bool _lastPage = false;

  bool get lastPage => _lastPage;

  Future refresh() async {
    print("Refreshing List...");
    _paging = Paging(rows: 100, page: 1);
    await _loadList();
  }

  bool _fetching = false;
  Future _loadList({bool nextPage = false}) async {
    _isLoaded = false;
    notifyListeners();

    if (!_fetching) {
      _fetching = true;
      var _items = await LeadRepository().loadList(auth, paging: _paging);

      List<dynamic> _result = _items?.result;

      if (_result?.isEmpty ?? true) {
        _lastPage = true;
      } else {
        var _results = _result
            ?.map((e) =>
                e == null ? null : LeadRow.fromJson(e as Map<String, dynamic>))
            ?.toList();

        if (nextPage) {
          _leads.addAll(_results);
        } else {
          _leads = _results;
        }

        _lastPage = false;
      }

      // // -- Dummy Data --
      // _leads = [
      //   LeadRow(id: "0", firstName: "Alfred", lastName: "Test"),
      //   LeadRow(id: "1", firstName: "Blfred", lastName: "Cest"),
      //   LeadRow(id: "2", firstName: "Clfred", lastName: "Dest"),
      //   LeadRow(id: "3", firstName: "Dlfred", lastName: "Rest"),
      //   LeadRow(id: "4", firstName: "Rlfred", lastName: "Iest"),
      // ];
      // _lastPage = true;

      _isLoaded = true;
      _fetching = false;
    }

    notifyListeners();
  }

  void fetchNext() {
    if (!_lastPage) {
      print("Fetching Next Page...");
      _paging.page = _paging.page + 1;
      _loadList(nextPage: true);
    }
  }
}