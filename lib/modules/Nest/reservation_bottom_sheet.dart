import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:yelpable/models/yelp_metadata_model.dart';
import 'package:yelpable/utils/sf_font.dart';

class ReservationBottomSheet extends StatefulWidget {
  final Business business;
  final int partySize;
  final String timeSlot;
  final VoidCallback onConfirmed;

  const ReservationBottomSheet({
    super.key,
    required this.business,
    required this.partySize,
    required this.timeSlot,
    required this.onConfirmed,
  });

  @override
  State<ReservationBottomSheet> createState() => _ReservationBottomSheetState();
}

class _ReservationBottomSheetState extends State<ReservationBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isProcessing = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 0.75.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _showSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      key: const ValueKey('form'),
      children: [
        // Handle
        SizedBox(height: 12.h),
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Reservation',
                    style: SFPro.font(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Confirm your booking at ${widget.business.name}',
                    style: SFPro.font(fontSize: 14.sp, color: Colors.black54),
                  ),

                  SizedBox(height: 24.h),

                  // Reservation Summary
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          CupertinoIcons.person_2_fill,
                          'Party Size',
                          '${widget.partySize} guests',
                        ),
                        Divider(height: 20.h, color: const Color(0xFFE5E5EA)),
                        _buildSummaryRow(
                          CupertinoIcons.clock_fill,
                          'Time',
                          widget.timeSlot,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Personal Information
                  Text(
                    'Personal Information',
                    style: SFPro.font(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: CupertinoIcons.person,
                    hint: 'John Doe',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: CupertinoIcons.mail,
                    hint: 'john@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Phone Field
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: CupertinoIcons.phone,
                    hint: '+1 (555) 123-4567',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Terms and Conditions
                  GestureDetector(
                    onTap: () =>
                        setState(() => _agreedToTerms = !_agreedToTerms),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: _agreedToTerms
                                ? const Color(0xFF007AFF)
                                : Colors.white,
                            border: Border.all(
                              color: _agreedToTerms
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFFD1D1D6),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: _agreedToTerms
                              ? Icon(
                                  CupertinoIcons.check_mark,
                                  size: 14.sp,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: SFPro.font(
                                fontSize: 13.sp,
                                color: const Color(0xFF3C3C43),
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: SFPro.font(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF007AFF),
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: SFPro.font(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF007AFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),

        // Bottom Button
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: const Color(0xFFE5E5EA), width: 1),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: _isProcessing ? Colors.grey : const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(12.r),
                onPressed: _isProcessing ? null : _handleConfirmReservation,
                child: _isProcessing
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Text(
                        'Confirm Reservation',
                        style: SFPro.font(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            color: const Color(0xFF34C759).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.check_mark_circled_solid,
            size: 60.sp,
            color: const Color(0xFF34C759),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Reservation Confirmed!',
          style: SFPro.font(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Your table for ${widget.partySize} at ${widget.business.name} is confirmed for ${widget.timeSlot}',
            textAlign: TextAlign.center,
            style: SFPro.font(
              fontSize: 15.sp,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Confirmation sent to ${_emailController.text}',
          style: SFPro.font(fontSize: 13.sp, color: const Color(0xFF8E8E93)),
        ),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: CupertinoButton(
              color: const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(12.r),
              onPressed: () {
                Get.back();
                widget.onConfirmed();
              },
              child: Text(
                'Done',
                style: SFPro.font(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF007AFF)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: SFPro.font(
                  fontSize: 12.sp,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: SFPro.font(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SFPro.font(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: SFPro.font(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black38,
            ),
            prefixIcon: Icon(icon, size: 20.sp, color: const Color(0xFF8E8E93)),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFF007AFF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            errorStyle: SFPro.font(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.red,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
          style: SFPro.font(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirmReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      Get.snackbar(
        'Agreement Required',
        'Please agree to the Terms & Conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _showSuccess = true;
    });
  }
}
