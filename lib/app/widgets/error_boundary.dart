import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return widget.fallback ?? _buildErrorWidget();
    }
    
    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[300],
              ),
              SizedBox(height: 20),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'We apologize for the inconvenience.\nPlease try again.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasError = false;
                    error = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00ADD9),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleError(Object error, StackTrace stackTrace) {
    print('Error caught by ErrorBoundary: $error');
    print('StackTrace: $stackTrace');
    
    setState(() {
      hasError = true;
      this.error = error;
    });
  }
}