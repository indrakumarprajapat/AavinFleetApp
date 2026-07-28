import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/collection_form_field.dart';
import '../controllers/collection_submit_controller.dart';

class CollectionSubmitView extends GetView<CollectionSubmitController> {
  const CollectionSubmitView({super.key});

  static const _teal1 = Color(0xFF007EA7);
  static const _bg = Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _teal1,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          controller.isMcr ? 'Submit at BMC' : 'Submit at Dairy',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Obx(() {
              if (controller.collectedSummary.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Text(
                  'Collected so far: ${controller.collectedSummary.value}',
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              );
            }),
            CollectionSectionCard(
              title: controller.isMcr ? 'BMC receipt' : 'Dairy receipt',
              subtitle:
                  'All fields marked * are required before confirming submit.',
              children: controller.isMcr ? _mcrFields() : _mtrFields(),
            ),
            CollectionSectionCard(
              title: 'Notes',
              children: [
                CollectionFormField(
                  controller: controller.remarksCtrl,
                  label: 'Remarks',
                  required: false,
                  hint: 'Optional',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal1,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.blueGrey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submit,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'CONFIRM SUBMIT',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<Widget> _mcrFields() => [
        CollectionFormField(
          controller: controller.canCountCtrl,
          label: 'Total cans',
          required: true,
          keyboard: TextInputType.number,
          validator: (v) => controller.validatePositive(v, 'Total cans'),
        ),
        CollectionFormField(
          controller: controller.canSizeCtrl,
          label: 'Can size (Ltr)',
          required: true,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => controller.validatePositive(v, 'Can size'),
        ),
        CollectionFormField(
          controller: controller.milkQtyCtrl,
          label: 'Total liters',
          required: true,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => controller.validatePositive(v, 'Total liters'),
        ),
        CollectionFormField(
          controller: controller.fatCtrl,
          label: 'Fat %',
          required: true,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => controller.validatePercent(v, 'Fat %'),
        ),
        CollectionFormField(
          controller: controller.snfCtrl,
          label: 'SNF %',
          required: true,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => controller.validatePercent(v, 'SNF %'),
        ),
      ];

  List<Widget> _mtrFields() => [
        CollectionFormField(
          controller: controller.fcLtrCtrl,
          label: 'FC liters',
          required: true,
          hint: 'Enter 0 if empty',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'FC liters is required';
            final n = double.tryParse(v.trim());
            if (n == null || n < 0) return 'Enter a valid number';
            return null;
          },
        ),
        CollectionFormField(
          controller: controller.mcLtrCtrl,
          label: 'MC liters',
          required: true,
          hint: 'Enter 0 if empty',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'MC liters is required';
            final n = double.tryParse(v.trim());
            if (n == null || n < 0) return 'Enter a valid number';
            return null;
          },
        ),
        CollectionFormField(
          controller: controller.rcLtrCtrl,
          label: 'RC liters',
          required: true,
          hint: 'Enter 0 if empty',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'RC liters is required';
            final n = double.tryParse(v.trim());
            if (n == null || n < 0) return 'Enter a valid number';
            return null;
          },
        ),
        CollectionFormField(
          controller: controller.fatCtrl,
          label: 'Fat % (overall)',
          required: true,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => controller.validatePercent(v, 'Fat %'),
        ),
        CollectionFormField(
          controller: controller.snfCtrl,
          label: 'SNF % (overall)',
          required: true,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => controller.validatePercent(v, 'SNF %'),
        ),
      ];
}
