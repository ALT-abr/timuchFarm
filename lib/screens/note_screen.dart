import 'package:flutter/material.dart';
import 'package:timuchmilk/database/farm_repository.dart';
import 'package:timuchmilk/models/note_model.dart';
import 'package:timuchmilk/widgets/page_header_card.dart';
import 'package:timuchmilk/widgets/responsive_layout.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late Future<List<NoteModel>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    _notesFuture = FarmRepository.instance.getNotes();
  }

  Future<void> _deleteNote(NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Note'),
          content: Text(
            'Delete "${note.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB64034),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await FarmRepository.instance.deleteNote(note.id!);

    if (!mounted) {
      return;
    }

    setState(_refreshNotes);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note deleted successfully.'),
      ),
    );
  }

  Future<void> _showAddNoteDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String category = 'Planning';
    String priority = 'medium';
    DateTime dueDate = DateTime.now();
    String? errorText;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text('Add Note'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Urgent',
                            child: Text('Urgent'),
                          ),
                          DropdownMenuItem(
                            value: 'Planning',
                            child: Text('Planning'),
                          ),
                          DropdownMenuItem(
                            value: 'Supply',
                            child: Text('Supply'),
                          ),
                          DropdownMenuItem(
                            value: 'Maintenance',
                            child: Text('Maintenance'),
                          ),
                          DropdownMenuItem(
                            value: 'Idea',
                            child: Text('Idea'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => category = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'high',
                            child: Text('High'),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(
                            value: 'low',
                            child: Text('Low'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => priority = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() => dueDate = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFBDB4AF)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded),
                              const SizedBox(width: 10),
                              Text(
                                _formatDate(dueDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty || description.isEmpty) {
                      setDialogState(() {
                        errorText = 'Please fill in title and description.';
                      });
                      return;
                    }

                    await FarmRepository.instance.addNote(
                      NoteModel(
                        title: title,
                        description: description,
                        category: category,
                        priority: priority,
                        dueDate: dueDate,
                        createdAt: DateTime.now(),
                      ),
                    );

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (created == true && mounted) {
      setState(_refreshNotes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added successfully.'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.of(context).size.width < 800;

    return ResponsiveLayout(
      title: "N O T E S",
      child: FutureBuilder<List<NoteModel>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Database error: ${snapshot.error}'));
          }

          final notes = snapshot.data ?? const <NoteModel>[];
          final urgentCount =
              notes.where((note) => note.priority.toLowerCase() == 'high').length;
          final now = DateTime.now();
          final weekLimit = now.add(const Duration(days: 7));
          final upcomingCount = notes
              .where(
                (note) =>
                    !note.dueDate.isBefore(now.subtract(const Duration(days: 1))) &&
                    !note.dueDate.isAfter(weekLimit),
              )
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeaderCard(
                  title: "Farm Notes",
                  description:
                      "Keep track of the important actions, reminders, and checks for the farm.",
                  action: FilledButton.icon(
                    onPressed: _showAddNoteDialog,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6D7F45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Add Note",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF6F0EA),
                      Color(0xFFECE5DE),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  titleColor: const Color(0xFF3A2929),
                  descriptionColor: const Color(0xFF715F5F),
                  borderRadius: 24,
                  padding: const EdgeInsets.all(22),
                  maxContentWidth: 700,
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 14.0;
                    final width = constraints.maxWidth;
                    final columns = width >= 980
                        ? 3
                        : width >= 640
                            ? 2
                            : 1;
                    final cardWidth =
                        (width - (spacing * (columns - 1))) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _InfoCard(
                          width: cardWidth,
                          title: "Total Notes",
                          value: "${notes.length}",
                          subTitle: "saved",
                          icon: Icons.note_alt_outlined,
                          color: const Color(0xFF6F8D42),
                        ),
                        _InfoCard(
                          width: cardWidth,
                          title: "Urgent Tasks",
                          value: "$urgentCount",
                          subTitle: "priority",
                          icon: Icons.priority_high_rounded,
                          color: const Color(0xFFD75E4A),
                        ),
                        _InfoCard(
                          width: cardWidth,
                          title: "Planned This Week",
                          value: "$upcomingCount",
                          subTitle: "upcoming",
                          icon: Icons.calendar_month_rounded,
                          color: const Color(0xFFB5964A),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                if (notes.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE8DEDA)),
                    ),
                    child: const Text(
                      "No notes yet. Use Add Note to create your first note.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6E5C5C),
                      ),
                    ),
                  )
                else
                  Column(
                    children: notes
                        .map(
                          (note) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _NoteDetailsCard(
                              title: note.title,
                              date: _formatDate(note.dueDate),
                              category: note.category,
                              description: note.description,
                              icon: _noteIcon(note.category),
                              iconColor: _noteColor(note.category),
                              isCompact: isCompact,
                              onDelete: () => _deleteNote(note),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _noteIcon(String category) {
    switch (category.toLowerCase()) {
      case 'urgent':
        return Icons.priority_high_rounded;
      case 'planning':
        return Icons.calendar_month_rounded;
      case 'supply':
        return Icons.shopping_bag_outlined;
      case 'maintenance':
        return Icons.build_circle_outlined;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  Color _noteColor(String category) {
    switch (category.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFD75E4A);
      case 'planning':
        return const Color(0xFFB5964A);
      case 'supply':
        return const Color(0xFF6D9151);
      case 'maintenance':
        return const Color(0xFF6E86B2);
      default:
        return const Color(0xFFC59B3B);
    }
  }
}

class _InfoCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String subTitle;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subTitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shadowColor: const Color(0x16000000),
        margin: EdgeInsets.zero,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 7,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteDetailsCard extends StatelessWidget {
  final String title;
  final String date;
  final String category;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isCompact;
  final VoidCallback onDelete;

  const _NoteDetailsCard({
    required this.title,
    required this.date,
    required this.category,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.isCompact,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(
                    title: title,
                    date: date,
                    category: category,
                    icon: icon,
                    iconColor: iconColor,
                    isCompact: true,
                    onDelete: onDelete,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF695858),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _HeaderRow(
                      title: title,
                      date: date,
                      category: category,
                      icon: icon,
                      iconColor: iconColor,
                      isCompact: false,
                      onDelete: null,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF695858),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _DeleteNoteButton(onDelete: onDelete),
                ],
              ),
      ),
    );
  }
}

class _DeleteNoteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteNoteButton({
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: onDelete,
        tooltip: 'Delete note',
        icon: const Icon(
          Icons.delete_outline,
          size: 20,
          color: Color(0xFFB64034),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String title;
  final String date;
  final String category;
  final IconData icon;
  final Color iconColor;
  final bool isCompact;
  final VoidCallback? onDelete;

  const _HeaderRow({
    required this.title,
    required this.date,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.isCompact,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF312424),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECE6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF6F5959),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF97888B),
                    ),
                  ),
                ],
              ),
              if (!isCompact) const SizedBox(height: 0),
            ],
          ),
        ),
      ],
    );
  }
}
