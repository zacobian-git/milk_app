String timezoneDatabaseIdentifier(String platformIdentifier) =>
    switch (platformIdentifier) {
      'Asia/Calcutta' => 'Asia/Kolkata',
      _ => platformIdentifier,
    };
