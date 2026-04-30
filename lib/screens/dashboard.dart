import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'members.dart';
import 'contributions.dart';
import 'loans.dart';
import 'fines_welfare.dart';
import 'month_end.dart';
import 'year_end.dart';
import 'reports.dart';
import 'settings.dart';
import 'activity_log.dart';
import 'manual.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _menuButton(String title, VoidCallback onTap) {
    return SizedBox(
      width: 150,
      height: 100,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          child: Center(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.dashboard)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _menuButton(AppLocalizations.of(context)!.members, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersScreen()))),
            _menuButton(AppLocalizations.of(context)!.contributions, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContributionsScreen()))),
            _menuButton(AppLocalizations.of(context)!.loans, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen()))),
            _menuButton(AppLocalizations.of(context)!.finesWelfare, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinesWelfareScreen()))),
            _menuButton(AppLocalizations.of(context)!.monthEnd, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthEndScreen()))),
            _menuButton(AppLocalizations.of(context)!.yearEnd, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YearEndScreen()))),
            _menuButton(AppLocalizations.of(context)!.reports, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
            _menuButton(AppLocalizations.of(context)!.settings, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            _menuButton(AppLocalizations.of(context)!.activityLog, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityLogScreen()))),
            _menuButton(AppLocalizations.of(context)!.userManual, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManualScreen()))),
          ],
        ),
      ),
    );
  }
}
