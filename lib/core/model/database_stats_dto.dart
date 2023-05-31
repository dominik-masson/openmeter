class DatabaseStatsDto {
  int? sumMeters;
  int? sumRooms;
  int? sumContracts;
  int? sumEntries;
  int? sumTags;

  DatabaseStatsDto({
    required this.sumMeters,
    required this.sumContracts,
    required this.sumEntries,
    required this.sumRooms,
    required this.sumTags,
  });
}
