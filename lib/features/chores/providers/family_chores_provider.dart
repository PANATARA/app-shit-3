import '../../../core/swr/swr.dart';
import '../models/chore_item_model.dart';
import '../repositories/chores_repository.dart';

final familyChoresSwr = createSwrProvider<List<ChoreItem>>(
  key: 'family-chores',
  fetcher: (ref) => ref.read(choresRepositoryProvider).getFamilyChores(),
  decoder: (json) => (json as List)
      .map((e) => ChoreItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);

final defaultChoresSwr = createSwrProvider<List<ChoreItem>>(
  key: 'default-chores',
  fetcher: (ref) => ref.read(choresRepositoryProvider).getDefaultChores(),
  decoder: (json) => (json as List)
      .map((e) => ChoreItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  encoder: (data) => data.map((e) => e.toJson()).toList(),
);
