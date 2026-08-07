import 'dart:convert';

import 'package:flutterpractisetasks/permissions/hard/models/draftmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharepreferencesService {
  static const String _preKey = 'report_cache';
  static const String _draftPreKey = 'draft_cache';

  // REPORT
  // Lưu toàn bộ reports
  Future<void> saveAllReports(List<ReportModel> reports) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = reports.map((d) => d.toJson()).toList();
    await prefs.setString(_preKey, jsonEncode(jsonList));
  }

  Future<bool> saveReport(ReportModel report) async {
    final prefs = await SharedPreferences.getInstance();

    // Đọc danh sách hiện tại trước
    final existing = await getReports() ?? [];

    final result = existing.any((t) => t.reportId == report.reportId);
    if (result) {
      return false;
    } else {
      // Thêm report mới vào
      existing.add(report);
      // Convert cả danh sách thành JSON array rồi ghi lại
      final jsonList = existing.map((r) => r.toJson()).toList();
      await prefs.setString(_preKey, jsonEncode(jsonList));
      return true;
    }
  }

  Future<List<ReportModel>?> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preKey);

    if (jsonString == null) return null;
    final List<dynamic> jsonList = jsonDecode(
      jsonString,
    ); // Dòng này chuyển chuỗi sang json nè

    final items = jsonList.map((j) => ReportModel.fromJson(j)).toList();
    return items;
  }

  // DRAFT
  // Lưu toàn bộ draft
  Future<void> saveAllDaft(List<Draftmodel> drafts) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = drafts.map((d) => d.toJson()).toList();
    await prefs.setString(_draftPreKey, jsonEncode(jsonList));
  }

  // Lưu 1 draft
  Future<bool> saveDaft(Draftmodel draft) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getDraft() ?? [];

    final existed = existing.any((d) => d.draftId == draft.draftId);
    if (existed) {
      return false;
    } else {
      existing.add(draft);

      final jsonList = existing.map((d) => d.toJson()).toList();
      await prefs.setString(_draftPreKey, jsonEncode(jsonList));
      return true;
    }
  }

  // Xóa 1 draft
  Future<void> deleteDraft(String draftId) async {
    final drafts = await getDraft() ?? [];

    drafts.removeWhere((d) => d.draftId == draftId);

    await SharepreferencesService().saveAllDaft(drafts);
  }

  // Lấy danh sách drafts
  Future<List<Draftmodel>?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_draftPreKey);

    if (jsonString == null) return null;
    final List<dynamic> jsonList = jsonDecode(
      jsonString,
    ); // Dòng này chuyển chuỗi sang json nè

    final items = jsonList.map((j) => Draftmodel.fromJson(j)).toList();
    return items;
  }
}
