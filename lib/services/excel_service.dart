import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class ExcelService {
  /// Generate Excel file from survey responses
  ///
  /// Returns Excel file as bytes that can be downloaded
  Future<List<int>> generateExcel(List<Map<String, dynamic>> responses) async {
    // Create Excel workbook
    var excel = Excel.createExcel();

    // Use a specific sheet name
    String sheetName = 'Survey Responses';
    var sheet = excel[sheetName];
    // Remove the default sheet if it's different and empty
    if (excel.tables.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    // Define header style
    CellStyle headerStyle = CellStyle(
      bold: true,
      fontSize: 12,
      backgroundColorHex: ExcelColor.fromHexString(
        '#00796B',
      ), // Match app theme
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Add headers
    var headers = [
      'No',
      'Tanggal',
      'Waktu',
      'Pertanyaan 1',
      'Pertanyaan 2',
      'Pertanyaan 3',
      'Pertanyaan 4',
      'Rata-rata',
      'Tingkat Kepuasan',
      'Nama',
      'Email',
      'Telepon',
      'Komentar',
    ];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Add data rows
    for (var i = 0; i < responses.length; i++) {
      var response = responses[i];
      var rowIndex = i + 1;

      // Parse created_at
      DateTime createdAt =
          DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now();
      String tanggal = DateFormat('dd/MM/yyyy').format(createdAt);
      String waktu = DateFormat('HH:mm:ss').format(createdAt);

      // Get ratings
      int q1 = response['question_1_rating'] ?? 0;
      int q2 = response['question_2_rating'] ?? 0;
      int q3 = response['question_3_rating'] ?? 0;
      int q4 = response['question_4_rating'] ?? 0;

      // Calculate average (of existing ratings)
      int nonZeroCount = 0;
      int totalSum = 0;
      if (q1 > 0) {
        totalSum += q1;
        nonZeroCount++;
      }
      if (q2 > 0) {
        totalSum += q2;
        nonZeroCount++;
      }
      if (q3 > 0) {
        totalSum += q3;
        nonZeroCount++;
      }
      if (q4 > 0) {
        totalSum += q4;
        nonZeroCount++;
      }

      double average = nonZeroCount > 0 ? totalSum / nonZeroCount : 0.0;

      // Determine satisfaction level
      String satisfaction;
      if (average >= 3.5) {
        satisfaction = 'Sangat Puas';
      } else if (average >= 2.5) {
        satisfaction = 'Puas';
      } else if (average >= 1.5) {
        satisfaction = 'Kurang Puas';
      } else {
        satisfaction = 'Tidak Puas';
      }

      // Add row data
      var rowData = [
        rowIndex, // No
        tanggal, // Tanggal
        waktu, // Waktu
        _getRatingLabel(q1), // Q1
        _getRatingLabel(q2), // Q2
        _getRatingLabel(q3), // Q3
        _getRatingLabel(q4), // Q4
        average.toStringAsFixed(2), // Rata-rata
        satisfaction, // Tingkat Kepuasan
        response['respondent_name'] ?? '-', // Nama
        response['respondent_email'] ?? '-', // Email
        response['respondent_phone'] ?? '-', // Telepon
        response['additional_comments'] ?? '-', // Komentar
      ];

      for (var j = 0; j < rowData.length; j++) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
        );
        cell.value = TextCellValue(rowData[j].toString());

        // Center align for some columns
        if (j < 9) {
          cell.cellStyle = CellStyle(
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
          );
        }
      }
    }

    // Encode to bytes
    var fileBytes = excel.encode();
    return fileBytes!;
  }

  /// Convert rating number to label
  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return '😞 Tidak Sesuai';
      case 2:
        return '😐 Kurang Sesuai';
      case 3:
        return '🙂 Sesuai';
      case 4:
        return '😄 Sangat Sesuai';
      default:
        return '-';
    }
  }
}
