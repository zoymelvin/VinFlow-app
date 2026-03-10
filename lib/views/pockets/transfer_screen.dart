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

  void _showConfirmationDialog() {
    final String amountText = _amountController.text;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Konfirmasi Transfer", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text("Apakah kamu yakin ingin mengirim saldo sebesar:", 
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            const SizedBox(height: 8),
            Text("Rp $amountText", 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: const Color(0xFF007BFF))),
            const SizedBox(height: 8),
            Text("ke ${selectedTarget?.name}?", 
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13)),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
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
      Navigator.pop(context); 
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
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      ),
      // FIX: Gunakan bottomNavigationBar agar tombol stay di bawah dan tidak menutupi input
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 24, 
          right: 24, 
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 24, 
          top: 10
        ),
        color: const Color(0xFFF8FAFC),
        child: _buildSubmitButton(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransferFlowVisual(),
            
            const SizedBox(height: 32),
            Text("Pilih Kantong Tujuan", 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF1E293B))),
            const SizedBox(height: 16),
            
            _buildTargetSelector(pockets),

            const SizedBox(height: 32),
            Text("Nominal Transfer", 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF1E293B))),
            const SizedBox(height: 16),
            
            _buildAmountField(),
            
            const SizedBox(height: 20), // Memberi ruang scroll di bawah
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return CupertinoTextField(
      controller: _amountController,
      placeholder: "0",
      keyboardType: TextInputType.number,
      padding: const EdgeInsets.all(20),
      style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text("Rp", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandsSeparatorInputFormatter(),
      ],
    );
  }

  Widget _buildTransferFlowVisual() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _miniPocketCard(widget.sourcePocket, "Dari"),
          Column(
            children: [
              Icon(CupertinoIcons.chevron_right_2, color: Colors.blue.withValues(alpha: 0.3), size: 20),
              const SizedBox(height: 4),
              Container(width: 40, height: 2, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(2))),
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
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(p.icon, color: p.color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(p.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _emptyTargetCard() {
    return Column(
      children: [
        Text("Ke", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
          child: const Icon(CupertinoIcons.question, color: Color(0xFFCBD5E1), size: 28),
        ),
        const SizedBox(height: 12),
        Text("Pilih Tujuan", style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFFCBD5E1), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTargetSelector(List<Pocket> pockets) {
    return SizedBox(
      height: 110,
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
              width: 100,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: isSelected ? p.color : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isSelected ? p.color : const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: isSelected ? [BoxShadow(color: p.color.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 6))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(p.icon, color: isSelected ? Colors.white : p.color, size: 24),
                  const SizedBox(height: 8),
                  Text(p.name, 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, 
                      fontWeight: FontWeight.w800,
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
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isButtonEnabled ? _showConfirmationDialog : null,
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isButtonEnabled ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text("Konfirmasi Transfer", 
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, 
            fontSize: 16, 
            color: _isButtonEnabled ? Colors.white : const Color(0xFF94A3B8)
          )),
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