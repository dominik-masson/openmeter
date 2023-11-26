class DatabaseStatsDto {
  int sumMeters;
  int sumRooms;
  int sumContracts;
  int sumEntries;
  int sumTags;
  int sumImages;

  DatabaseStatsDto({
    required this.sumMeters,
    required this.sumContracts,
    required this.sumEntries,
    required this.sumRooms,
    required this.sumTags,
    required this.sumImages,
  });
}
