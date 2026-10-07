/// Enterprise wall-clock time, independent of the device time zone.
DateTime enterpriseTime(DateTime instant) =>
    instant.toUtc().add(const Duration(hours: 5));
