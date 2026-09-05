import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int tab = 0;
  Map<String, dynamic> data = {};
  List<Map<String, dynamic>> tasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    try {
      final r = await apiClient.get('/dashboard/snapshot');
      final t = await apiClient.get('/tasks');

      if (mounted) {
        setState(() {
          data = r;

          final rawTasks = t['data'] is List
              ? t['data'] as List
              : t.values
                  .whereType<List>()
                  .expand((items) => items)
                  .toList();

          tasks = rawTasks
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _complete(Map<String, dynamic> task) async {
    try {
      await apiClient.put(
        '/tasks/${task['id']}',
        {'status': 'completed'},
      );

      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not update task: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      _journey(),
      _tasks(),
      _intelligence(),
      _skills(),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: pages[tab],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/iv'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask IV'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) {
          setState(() => tab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Journey',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Intel',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Skills',
          ),
        ],
      ),
    );
  }

  Widget _top(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _home() {
    final scores = Map<String, dynamic>.from(
      (data['scores'] as Map?) ?? {},
    );

    final metrics = Map<String, dynamic>.from(
      (data['metrics'] as Map?) ?? {},
    );

    final next = Map<String, dynamic>.from(
      (data['nextAction'] as Map?) ?? {},
    );

    final business = Map<String, dynamic>.from(
      (data['business'] as Map?) ?? {},
    );

    final first = appState.name?.split(' ').first ?? 'Founder';

    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'morning'
        : hour < 18
            ? 'afternoon'
            : 'evening';

    final industry = business['industry']?.toString() ?? '';

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          120,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good $greeting, $first',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      industry.isNotEmpty
                          ? 'Let’s move your $industry business forward.'
                          : 'Let’s move the business forward.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => appState.signOut(),
                tooltip: 'Sign out',
                icon: const Icon(
                  Icons.logout_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEXT BEST ACTION',
                    style: TextStyle(
                      color: AppColors.primaryBright,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    next['title']?.toString() ??
                        'Define your first measurable milestone',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${next['estimatedMinutes'] ?? 30} min • Customer-facing and measurable.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => tab = 2);
                    },
                    child: const Text(
                      'Open today’s tasks',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _score(
                  'Business health',
                  scores['businessHealth'] ?? 35,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _score(
                  'Founder growth',
                  scores['entrepreneurDevelopment'] ?? 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Momentum',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _metric(
                          '${metrics['tasksCompleted'] ?? 0}',
                          'tasks done',
                        ),
                      ),
                      Expanded(
                        child: _metric(
                          '${metrics['activityEntries'] ?? 0}',
                          'activity logs',
                        ),
                      ),
                      Expanded(
                        child: _metric(
                          '${metrics['skillsTracked'] ?? 0}',
                          'skills',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.elevated,
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryBright,
                ),
              ),
              title: const Text(
                'Need a decision?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: const Text(
                'IV uses your workspace context to keep advice practical.',
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () => context.push('/iv'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _score(String label, dynamic raw) {
    final parsed = raw is num
        ? raw.toDouble()
        : double.tryParse(raw.toString()) ?? 0;

    final value = parsed.clamp(0.0, 100.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${value.round()}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 6,
                backgroundColor: AppColors.elevated,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _tasks() {
    final pending = tasks
        .where(
          (task) => task['status'] != 'completed',
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        120,
      ),
      children: [
        _top(
          'Today’s tasks',
          'Do less. Finish what matters.',
        ),
        const SizedBox(height: 22),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          ),
        if (!loading && pending.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 42,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'You’re clear for now.',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Ask IV for the next experiment.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ...pending.map(
          (task) => Card(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              leading: IconButton(
                onPressed: () => _complete(task),
                icon: const Icon(
                  Icons.radio_button_unchecked,
                ),
              ),
              title: Text(
                task['title']?.toString() ??
                    'Untitled task',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                '${task['estimatedMinutes'] ?? 30} min • ${task['difficulty'] ?? 'focused'}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                ),
              ),
              onTap: () => _complete(task),
            ),
          ),
        ),
      ],
    );
  }

  Widget _journey() {
    const stages = [
      'Discover',
      'Research',
      'Validate',
      'Prototype',
      'Launch',
      'Early revenue',
      'Grow',
      'Scale',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        120,
      ),
      children: [
        _top(
          'Your journey',
          'A clear path from idea to scale.',
        ),
        const SizedBox(height: 22),
        ...stages.asMap().entries.map(
          (entry) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: entry.key == 0
                    ? AppColors.primary
                    : AppColors.elevated,
                child: Text(
                  '${entry.key + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              title: Text(
                entry.value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                entry.key == 0
                    ? 'Current focus'
                    : 'Build evidence before moving here.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                ),
              ),
              trailing: Icon(
                entry.key == 0
                    ? Icons.arrow_forward
                    : Icons.lock_outline,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _intelligence() {
    const items = [
      'Market signals',
      'Competitor moves',
      'Opportunities',
      'Risks',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        120,
      ),
      children: [
        _top(
          'Intelligence',
          'Signals that improve your decisions.',
        ),
        const SizedBox(height: 22),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(
                Icons.insights_outlined,
                color: AppColors.primaryBright,
              ),
              title: Text(
                item,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: const Text(
                'Connect verified evidence before acting.',
                style: TextStyle(
                  color: AppColors.textMuted,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _skills() {
    const items = [
      'Technical',
      'Business',
      'Communication',
      'Leadership',
      'Execution',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        120,
      ),
      children: [
        _top(
          'Skills',
          'Build the capabilities your business actually needs.',
        ),
        const SizedBox(height: 22),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(
                Icons.bolt_outlined,
                color: AppColors.primaryBright,
              ),
              title: Text(
                item,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: const Text(
                'Track your current capability and improve deliberately.',
                style: TextStyle(
                  color: AppColors.textMuted,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
