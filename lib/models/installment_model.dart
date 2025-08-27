class InstallmentModel {
  final String id;
  final String saleId;
  final DateTime dueDate;
  final double amount;
  bool isPaid;
  final double totalAmount; // New field
  final double downPayment; // New field
  final int numberOfMonths; // New field
  final double monthlyInstallment; // New field
  final DateTime dateCreated; // New field
  final String status; // New field

  InstallmentModel({
    required this.id,
    required this.saleId,
    required this.dueDate,
    required this.amount,
    this.isPaid = false,
    required this.totalAmount, // New field
    required this.downPayment, // New field
    required this.numberOfMonths, // New field
    required this.monthlyInstallment, // New field
    required this.dateCreated, // New field
    required this.status, // New field
  });

  // Add copyWith method (optional, but good practice if you plan to update installments)
  InstallmentModel copyWith({
    String? id,
    String? saleId,
    DateTime? dueDate,
    double? amount,
    bool? isPaid,
    double? totalAmount,
    double? downPayment,
    int? numberOfMonths,
    double? monthlyInstallment,
    DateTime? dateCreated,
    String? status,
  }) {
    return InstallmentModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      totalAmount: totalAmount ?? this.totalAmount,
      downPayment: downPayment ?? this.downPayment,
      numberOfMonths: numberOfMonths ?? this.numberOfMonths,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      dateCreated: dateCreated ?? this.dateCreated,
      status: status ?? this.status,
    );
  }
}