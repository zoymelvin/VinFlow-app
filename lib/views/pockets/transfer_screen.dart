import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/pocket_model.dart';
import '../../providers/pocket_provider.dart';

class TransferScreen extends StatefulWidget {
  final Pocket sourcePocket;
  const TransferScreen({super.key, required this.sourcePocket});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  Pocket? selectedTarget;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Listener untuk mengaktifkan/menonaktifkan tombol secara real-time
    _amountController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled = selectedTarget != null && _amountController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Fungsi Munculkan Popup Konfirmasi Sebelum Proses
  void _showConfirmationDialog() {
    final _ = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final String amountText = _amountController.text;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Konfirmasi Transfer", 
          style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text("Apakah kamu yakin ingin mengirim saldo sebesar:", 
              style: GoogleFonts.inter(fontSize: 13)),
            const SizedBox(height: 8),
            Text(amountText, 
              style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 8),
            Text("ke ${selectedTarget?.name}?", 
              style: GoogleFonts.inter(fontSize: 13)),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.pop(context); // Tutup Dialog
              _processTransfer();
            },
            child: const Text("Transfer Sekarang"),
          ),
        ],
      ),
    );
  }

  Future<void> _processTransfer() async {
    final amount = double.parse(_amountController.text.replaceAll('.', ''));
    
    if (amount > widget.sourcePocket.balance) {
      _showError("Saldo ${widget.sourcePocket.name} tidak cukup.");
      return;
    }

    final success = await context.read<PocketProvider>().transferBalance(
      fromPocket: widget.sourcePocket,
      toPocket: selectedTarget!,
      amount: amount,
    );

    if (success && mounted) {
      Navigator.pop(context); // Kembali ke Detail Screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final pockets = context.watch<PocketProvider>().pockets
        .where((p) => p.id != widget.sourcePocket.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CupertinoNavigationBar(
        middle: Text("Transfer Dana", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransferFlowVisual(),
            
            const SizedBox(height: 32),
            Text("Pilih Kantong Tujuan", 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1E293B))),
            const SizedBox(height: 16),
            
            _buildTargetSelector(pockets),

            const SizedBox(height: 32),
            Text("Nominal Transfer", 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1E293B))),
            const SizedBox(height: 16),
            
            CupertinoTextField(
              controller: _amountController,
              placeholder: "0",
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.all(20),
              style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              prefix: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text("Rp", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.grey)),
              ),
              // FIX 1: Tambahkan Formatter Titik Ribuan
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ThousandsSeparatorInputFormatter(),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // FIX 2: Tombol diperbaiki logikanya
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferFlowVisual() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _miniPocketCard(widget.sourcePocket, "Dari"),
          Column(
            children: [
              const Icon(CupertinoIcons.chevron_right_2, color: Color(0xFFCBD5E1), size: 20),
              const SizedBox(height: 4),
              Container(width: 40, height: 2, color: const Color(0xFFF1F5F9)),
            ],
          ),
          selectedTarget == null ? _emptyTargetCard() : _miniPocketCard(selectedTarget!, "Ke"),
        ],
      ),
    );
  }

  Widget _miniPocketCard(Pocket p, String label) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(p.icon, color: p.color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(p.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }

  Widget _emptyTargetCard() {
    return Column(
      children: [
        Text("Ke", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), shape: BoxShape.circle),
          child: const Icon(CupertinoIcons.question, color: Colors.grey, size: 28),
        ),
        const SizedBox(height: 12),
        Text("Pilih Tujuan", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTargetSelector(List<Pocket> pockets) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: pockets.length,
        itemBuilder: (context, index) {
          final p = pockets[index];
          bool isSelected = selectedTarget?.id == p.id;
          return GestureDetector(
            onTap: () {
              setState(() => selectedTarget = p);
              _validateForm();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 110,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? p.color : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: isSelected ? p.color : const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: isSelected ? [BoxShadow(color: p.color.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(p.icon, color: isSelected ? Colors.white : p.color, size: 26),
                  const SizedBox(height: 10),
                  Text(p.name, 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, 
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF475569))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        // FIX 2: Logika ketersediaan tombol
        onPressed: _isButtonEnabled ? _showConfirmationDialog : null,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isButtonEnabled ? const Color(0xFF007BFF) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isButtonEnabled ? [BoxShadow(color: const Color(0xFF007BFF).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))] : [],
          ),
          child: Text("Konfirmasi Transfer", 
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, 
              fontSize: 17, 
              color: _isButtonEnabled ? Colors.white : Colors.grey.shade500
            )),
        ),
      ),
    );
  }

  void _showError(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (c) => CupertinoAlertDialog(
        title: const Text("Gagal"),
        content: Text(msg),
        actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
      ),
    );
  }
}

// FORMATTER TITIK RIBUAN
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
      selection: TextSelection.collapsed(offset: newText.length)
    );
  }
}