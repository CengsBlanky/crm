package com.zengshuai.crm.settings.service;

import com.zengshuai.crm.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

public interface DicService {
    Map<String, List<DicValue>> getDicInfo();
}
