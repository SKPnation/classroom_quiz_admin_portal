import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/widgets/action_card_item.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/widgets/dashboard_top_nav.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/widgets/kpi_card_item.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/widgets/performance_overview_card.dart';
import 'package:classroom_quiz_admin_portal/features/dashboard/presentation/widgets/recent_quizzes_card.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final dashboardController = DashboardController.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1st layer
        dashboardTopNavigationBar(context),
        const SizedBox(height: 16),

        // Give the scroll view height to avoid bottom overflow
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (_, constraints) {
                    final twoUp = constraints.maxWidth >= 900;

                    return twoUp
                        ? Row(
                            children: dashboardController.kpiCards
                                .asMap()
                                .entries
                                .map((entry) {
                                  final i = entry.key;
                                  final e = entry.value;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right:
                                            i ==
                                                dashboardController
                                                        .kpiCards
                                                        .length -
                                                    1
                                            ? 0
                                            : 12,
                                      ),
                                      child: KpiCardItem(
                                        isLast:
                                            i ==
                                            dashboardController
                                                    .kpiCards
                                                    .length -
                                                1,
                                        title: e.title,
                                        value: e.value,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: dashboardController.kpiCards
                                .asMap()
                                .entries
                                .map((entry) {
                                  final i = entry.key;
                                  final e = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          i ==
                                              dashboardController
                                                      .kpiCards
                                                      .length -
                                                  1
                                          ? 0
                                          : 12,
                                    ),
                                    child: KpiCardItem(
                                      isLast:
                                          i ==
                                          dashboardController.kpiCards.length -
                                              1,
                                      title: e.title,
                                      value: e.value,
                                    ),
                                  );
                                })
                                .toList(),
                          );
                  },
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (_, constraints) {
                    final twoUp = constraints.maxWidth >= 900;

                    return twoUp
                        ? Row(
                            children: dashboardController.actionCards
                                .asMap()
                                .entries
                                .map((entry) {
                                  final i = entry.key;
                                  final e = entry.value;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right:
                                            i ==
                                                dashboardController
                                                        .actionCards
                                                        .length -
                                                    1
                                            ? 0
                                            : 12,
                                      ),
                                      child: ActionCardItem(
                                        isLast:
                                            i ==
                                            dashboardController
                                                    .actionCards
                                                    .length -
                                                1,
                                        actionCard: e,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: dashboardController.actionCards
                                .asMap()
                                .entries
                                .map((entry) {
                                  final i = entry.key;
                                  final e = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          i ==
                                              dashboardController
                                                      .actionCards
                                                      .length -
                                                  1
                                          ? 0
                                          : 12,
                                    ),
                                    child: ActionCardItem(
                                      isLast:
                                          i ==
                                          dashboardController
                                                  .actionCards
                                                  .length -
                                              1,
                                      actionCard: e,
                                    ),
                                  );
                                })
                                .toList(),
                          );
                  },
                ),

                SizedBox(height: 12),
                LayoutBuilder(
                  builder: (_, constraints) {
                    final twoUp = constraints.maxWidth >= 900;

                    return twoUp
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Expanded(
                                flex: 2,
                                child: PerformanceOverviewCard(),
                              ),
                              SizedBox(width: 12),
                              Expanded(child: RecentQuizzesCard()),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PerformanceOverviewCard(),
                              SizedBox(height: 12),
                              RecentQuizzesCard(),
                            ],
                          );
                  },
                ),
              ],
            ),

            // Column(
            //   children: [
            //     // 2nd layer
            //     Row(
            //       children: dashboardController.kpiCards
            //           .asMap()
            //           .entries
            //           .map((entry) {
            //         final i = entry.key;
            //         final e = entry.value;
            //         return Expanded(
            //           child: KpiCardItem(
            //             isLast: i == dashboardController.kpiCards.length - 1,
            //             title: e.title,
            //             value: e.value,
            //           ),
            //         );
            //       }).toList(),
            //     ),
            //     const SizedBox(height: 16),
            //
            //     // 3rd layer
            //     Row(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: dashboardController.actionCards
            //           .asMap()
            //           .entries
            //           .map((entry) {
            //         final i = entry.key;
            //         final e = entry.value;
            //         return Expanded(
            //           child: ActionCardItem(
            //             isLast: i == dashboardController.actionCards.length - 1,
            //             actionCard: e,
            //           ),
            //         );
            //       }).toList(),
            //     ),
            //
            //     const SizedBox(height: 16),
            //
            //     // 4th layer
            //     Row(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: const [
            //         Expanded(flex: 2, child: PerformanceOverviewCard()),
            //         SizedBox(width: 16),
            //         Expanded(child: RecentQuizzesCard()),
            //       ],
            //     ),
            //   ],
            // ),
          ),
        ),
      ],
    );
  }
}
