import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/ccavenue_service.dart';

/// CCAvenue Payment Widget
/// Easy to use widget for CCAvenue payments
class CCavenuePaymentWidget extends StatefulWidget {
  final double amount;
  final int userId;
  final int userType;
  final int paymentFor;
  final Function(String status, String orderId, String amount)? onPaymentSuccess;
  final Function(String error)? onPaymentError;
  final VoidCallback? onPaymentCancel;

  const CCavenuePaymentWidget({
    Key? key,
    required this.amount,
    required this.userId,
    required this.paymentFor,
    required this.userType,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.onPaymentCancel,
  }) : super(key: key);

  @override
  _CCavenuePaymentWidgetState createState() => _CCavenuePaymentWidgetState();
}

class _CCavenuePaymentWidgetState extends State<CCavenuePaymentWidget> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount:'),
                      Text(CCavenueService.formatAmount(widget.amount), 
                           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('User Type:'),
                      Text(widget.userType == 1 ? 'Customer' : 'Agent'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          _loading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Pay ${CCavenueService.formatAmount(widget.amount)}'),
                ),
        ],
      ),
    );
  }

  void _initiatePayment() async {
    setState(() {
      _loading = true;
    });

    CCavenueService.makePayment(
      amount: widget.amount,
      userId: widget.userId,
      userType: widget.userType,
      paymentFor: widget.paymentFor,
      onSuccess: (status, orderId, amount) {
        setState(() {
          _loading = false;
        });
        if (widget.onPaymentSuccess != null) {
          widget.onPaymentSuccess!(status, orderId, amount);
        }
      },
      onError: (error) {
        setState(() {
          _loading = false;
        });
        if (widget.onPaymentError != null) {
          widget.onPaymentError!(error);
        }
      },
      onCancel: () {
        setState(() {
          _loading = false;
        });
        if (widget.onPaymentCancel != null) {
          widget.onPaymentCancel!();
        }
      },
    );
  }
}