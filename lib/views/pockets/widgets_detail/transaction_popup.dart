import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/pocket_model.dart';
import '../../../providers/pocket_provider.dart';

class TransactionPopup extends StatelessWidget {
  final Pocket pocket;
  final bool isTopUp;

  const TransactionPopup({
    super.key,
    required this.pocket,
    required this.isTopUp,
  });

  static void show(BuildContext context, Pocket pocket, bool isTopUp) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (navContext, anim1, anim2) {
        return TransactionPopup(pocket: pocket, isTopUp: isTopUp);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();
    final pocketProvider = Provider.of<PocketProvider>(context, listen: false);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isTopUp ? 'Isi Saldo' : 'Kurangi Saldo',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 24),
              CupertinoTextField(
                controller: amountController,
                placeholder: 'Nominal Rp',
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorInputFormatter(),
                ],
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton(
                      color: isTopUp ? const Color(0xFF10B981) : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () async {
                        if (amountController.text.isNotEmpty) {
                          final amount = double.parse(amountController.text.replaceAll('.', ''));
                          final currentPocket = pocketProvider.pockets.firstWhere((p) => p.id == pocket.id);

                          bool success;
                          if (isTopUp) {
                            success = await pocketProvider.topUpBalance(pocket.id, currentPocket.balance, amount);
                          } else {
                            success = await pocketProvider.withdrawBalance(pocket.id, currentPocket.balance, amount);
                          }

                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text('Proses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String newValueText = newValue.text.replaceAll('.', '');
    double? value = double.tryParse(newValueText);
    if (value == null) return oldValue;
    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(value);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}