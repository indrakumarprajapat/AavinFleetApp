import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/collection_form_field.dart';
import '../controllers/collection_stop_controller.dart';

class CollectionStopView extends GetView<CollectionStopController> {
  const CollectionStopView({super.key});

  static const _teal1 = Color(0xFF007EA7);
  static const _bg = Color(0xFFF4F7FB);

  bool get _locked => controller.isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _teal1,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          controller.stop.societyName ?? 'Collection stop',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            if (_locked)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: const Text(
                  'Milk already submitted. Collection values are locked.',
                  style: TextStyle(color: Color(0xFF1565C0), fontSize: 13),
                ),
              )
            else if (controller.isAlreadyDone)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Text(
                  'This stop was already marked. Saving will update the values.',
                  style: TextStyle(color: Color(0xFF6D4C41), fontSize: 13),
                ),
              ),
            CollectionSectionCard(
              title: controller.isMcr
                  ? 'Milk can collection'
                  : 'Tanker compartment fill',
              subtitle: controller.isMcr
                  ? 'Enter can count, quality (Fat / SNF). Liters auto-calculate.'
                  : 'Enter liters for compartments filled. Fat / SNF required for each filled compartment.',
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
                  readOnly: _locked,
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
                    onPressed: (controller.isLoading.value || _locked)
                        ? null
                        : () => controller.submitStop(),
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
                            'MARK COLLECTED',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                  ),
                )),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFEF9A9A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _locked ? null : () => controller.submitStop(skip: true),
                child: const Text(
                  'SKIP STOP',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _mcrFields() => [
        CollectionFormField(
          controller: controller.canCountCtrl,
          label: 'Can count',
          required: true,
          readOnly: _locked,
          keyboard: TextInputType.number,
          validator: (v) =>
              controller.validatePositiveNumber(v, 'Can count'),
          onChanged: (_) => controller.recalcMilkQty(),
        ),
        CollectionFormField(
          controller: controller.canSizeCtrl,
          label: 'Can size (Ltr)',
          required: true,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              controller.validatePositiveNumber(v, 'Can size'),
          onChanged: (_) => controller.recalcMilkQty(),
        ),
        CollectionFormField(
          controller: controller.milkQtyCtrl,
          label: 'Milk liters',
          required: true,
          readOnly: _locked,
          hint: 'Auto = cans × size',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              controller.validatePositiveNumber(v, 'Milk liters'),
        ),
        CollectionFormField(
          controller: controller.fatCtrl,
          label: 'Fat %',
          required: true,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => controller.validatePercent(v, 'Fat %'),
        ),
        CollectionFormField(
          controller: controller.snfCtrl,
          label: 'SNF %',
          required: true,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) => controller.validatePercent(v, 'SNF %'),
        ),
      ];

  List<Widget> _mtrFields() => [
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            'Front compartment (FC)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
        ),
        CollectionFormField(
          controller: controller.fcLtrCtrl,
          label: 'FC liters',
          required: false,
          readOnly: _locked,
          hint: '0 if empty',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final n = double.tryParse(v.trim());
            if (n == null || n < 0) return 'Enter a valid number';
            return null;
          },
        ),
        CollectionFormField(
          controller: controller.fcFatCtrl,
          label: 'FC Fat %',
          required: false,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              controller.validateCompartmentFat(v, controller.fcLtrCtrl),
        ),
        CollectionFormField(
          controller: controller.fcSnfCtrl,
          label: 'FC SNF %',
          required: false,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              controller.validateCompartmentSnf(v, controller.fcLtrCtrl),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4, bottom: 6),
          child: Text(
            'Middle compartment (MC)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
        ),
        CollectionFormField(
          controller: controller.mcLtrCtrl,
          label: 'MC liters',
          required: false,
          readOnly: _locked,
          hint: '0 if empty',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final n = double.tryParse(v.trim());
            if (n == null || n < 0) return 'Enter a valid number';
            return null;
          },
        ),
        CollectionFormField(
          controller: controller.mcFatCtrl,
          label: 'MC Fat %',
          required: false,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              controller.validateCompartmentFat(v, controller.mcLtrCtrl),
        ),
        CollectionFormField(
          controller: controller.mcSnfCtrl,
          label: 'MC SNF %',
          required: false,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              controller.validateCompartmentSnf(v, controller.mcLtrCtrl),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4, bottom: 6),
          child: Text(
            'Rear compartment (RC)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
        ),
        CollectionFormField(
          controller: controller.rcLtrCtrl,
          label: 'RC liters',
          required: false,
          readOnly: _locked,
          hint: '0 if empty',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final n = double.tryParse(v.trim());
            if (n == null || n < 0) return 'Enter a valid number';
            return null;
          },
        ),
        CollectionFormField(
          controller: controller.rcFatCtrl,
          label: 'RC Fat %',
          required: false,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              controller.validateCompartmentFat(v, controller.rcLtrCtrl),
        ),
        CollectionFormField(
          controller: controller.rcSnfCtrl,
          label: 'RC SNF %',
          required: false,
          readOnly: _locked,
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              controller.validateCompartmentSnf(v, controller.rcLtrCtrl),
        ),
      ];
}
