import 'package:flutter/material.dart';
import '../services/time_slots_service.dart';
import '../services/api_service.dart';

class QuickBookingPanel extends StatefulWidget {
  const QuickBookingPanel({super.key});

  @override
  State<QuickBookingPanel> createState() => _QuickBookingPanelState();
}

class _QuickBookingPanelState extends State<QuickBookingPanel> {
  // ==================== State Variables ====================
  String? _selectedServiceType;
  String? _selectedDoctor;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final List<String> _serviceTypes = [
     'Select Department',
     'Consultation',
     'Check-up',
     'Therapy',
     'Cardiology',
     'Neurology',
     'General Medicine',
     'Pediatrics',
     'Surgery',
     ];
  List<String> _doctors = [];
  List<AvailableTime> _availableHours = [];

  bool _isLoadingDoctors = false;
  bool _isLoadingTimes = false;

  // ==================== Date Constraints ====================
  DateTime get _now => DateTime.now();
  DateTime get _currentMonthFirstDay => DateTime(_now.year, _now.month, 1);
  DateTime get _nextMonthFirstDay => DateTime(_now.year, _now.month + 1, 1);

  // Takvim ay gösterimi için
  DateTime get _viewDateMonth =>
      DateTime(_selectedDate.year, _selectedDate.month, 1);

  bool _isDatePast(DateTime date) {
    final today = DateTime(_now.year, _now.month, _now.day);
    return date.isBefore(today);
  }

  // ==================== Backend Calls ====================
  Future<void> _loadDoctors(String serviceType) async {
    setState(() => _isLoadingDoctors = true);
    try {
      final docs = await ApiService.getDoctorsByService(serviceType);
      setState(() {
        _doctors = docs;
        _isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() => _isLoadingDoctors = false);
    }
  }

  Future<void> _loadAvailableHours() async {
    if (_selectedDoctor == null) return;
    setState(() {
      _isLoadingTimes = true;
      _selectedTime = null;
    });
    try {
      final dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final hours = await TimeSlotsService.getFilteredAvailableSlots(
        date: dateStr,
        doctor: _selectedDoctor!,
      );
      setState(() {
        _availableHours = hours;
        _isLoadingTimes = false;
      });
    } catch (e) {
      setState(() => _isLoadingTimes = false);
    }
  }

  // ==================== UI Components ====================
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Quick Appointment"),
              const SizedBox(height: 15),

              _buildLabel("1. Service Type"),
              _buildServiceDropdown(),

              const SizedBox(height: 15),

              _buildLabel("2. Doctor"),
              _buildDoctorDropdown(),

              if (_selectedDoctor != null) ...[
                const SizedBox(height: 25),
                _buildLabel("3. Select Date"),
                _buildCalendar(),

                const SizedBox(height: 25),
                _buildLabel("4. Select Time (1 Hour Slots)"),
                _buildTimeSlotsGrid(), // Alt alta sıkışmaması için Grid
              ],

              const SizedBox(height: 30),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final lastDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );
    final firstDayWeekday = _viewDateMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final bool isCurrentMonth = _viewDateMonth.isAtSameMomentAs(
      _currentMonthFirstDay,
    );
    final bool isNextMonth = _viewDateMonth.isAtSameMomentAs(
      _nextMonthFirstDay,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: isCurrentMonth
                    ? null
                    : () {
                        setState(() => _selectedDate = _currentMonthFirstDay);
                        _loadAvailableHours();
                      },
              ),
              Text(
                "${_selectedDate.month}/${_selectedDate.year}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: isNextMonth
                    ? null
                    : () {
                        setState(() => _selectedDate = _nextMonthFirstDay);
                        _loadAvailableHours();
                      },
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: firstDayWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstDayWeekday) return const SizedBox.shrink();
              final day = index - firstDayWeekday + 1;
              final date = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                day,
              );
              final isPast = _isDatePast(date);
              final isSelected = _selectedDate.day == day;

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
                        setState(() => _selectedDate = date);
                        _loadAvailableHours();
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : (isPast ? Colors.transparent : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.blue.shade100,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isPast ? Colors.grey : Colors.blue.shade900),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    if (_isLoadingTimes)
      return const Center(child: CircularProgressIndicator());
    if (_availableHours.isEmpty)
      return const Text("Please select a date to see hours.");

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Yan yana 3 saat
        childAspectRatio: 2.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _availableHours.length,
      itemBuilder: (context, index) {
        final slot = _availableHours[index];
        final isSelected = _selectedTime == slot.time;

        return GestureDetector(
          onTap: slot.available
              ? () => setState(() => _selectedTime = slot.time)
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.shade700
                  : (slot.available ? Colors.white : Colors.red.shade50),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Colors.blue.shade700
                    : (slot.available
                          ? Colors.blue.shade200
                          : Colors.red.shade200),
              ),
            ),
            child: Center(
              child: Text(
                slot.time,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (slot.available
                            ? Colors.blue.shade900
                            : Colors.red.shade300),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ... (Dropdown ve Label widgetları senin önceki kodunla aynı veya benzer şekilde)
  Widget _buildServiceDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedServiceType,
      items: _serviceTypes
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedServiceType = val;
          _selectedDoctor = null;
          _availableHours = [];
        });
        _loadDoctors(val!);
      },
      decoration: _inputDecoration(),
    );
  }

  Widget _buildDoctorDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDoctor,
      hint: Text(_isLoadingDoctors ? "Loading..." : "Select Doctor"),
      items: _doctors
          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
          .toList(),
      onChanged: _selectedServiceType == null
          ? null
          : (val) {
              setState(() => _selectedDoctor = val);
              _loadAvailableHours();
            },
      decoration: _inputDecoration(),
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  );

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    ),
  );

  Widget _buildSectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    ),
  );

  Widget _buildConfirmButton() {
    bool isReady = _selectedDoctor != null && _selectedTime != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? Colors.blue : Colors.grey,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isReady ? () => _confirmBooking() : null,
        child: const Text(
          "Confirm Appointment",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _confirmBooking() async {
    // Yükleme SnackBar'ı göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu oluşturuluyor...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Tarih ve saati backend'in beklediği formatta birleştiriyoruz (YYYY-MM-DD)
    final String formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    try {
      final Map<String, dynamic> appointmentData = {
        'doctor': _selectedDoctor,
        'service': _selectedServiceType,
        'date':
            formattedDate, // Sadece tarih (Backend'de date::date olarak işlenecek)
        'time': _selectedTime, // "09:00" formatında
        'notes': 'Hızlı Panel üzerinden alındı',
        'duration': 60, // 1 saatlik blok
      };

      final result = await ApiService.createAppointment(appointmentData);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Randevu başarıyla onaylandı!'),
            backgroundColor: Colors.green,
          ),
        );

        // Başarılı kayıttan sonra seçimleri sıfırla ve saatleri güncelle
        setState(() {
          _selectedTime = null;
        });
        _loadAvailableHours(); // Dolan saati listeden düşürmek için tekrar yükle
      } else {
        throw Exception(result['message'] ?? 'Randevu oluşturulamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
