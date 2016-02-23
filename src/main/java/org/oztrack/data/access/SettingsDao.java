package org.oztrack.data.access;

import org.oztrack.data.model.Settings;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;

@Service
public interface SettingsDao {
    Settings getSettings();
    Settings update(Settings settings);
    LinkedHashMap<String, Long> getSummaryStatistics();
}

