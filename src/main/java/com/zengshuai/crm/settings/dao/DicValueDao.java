package com.zengshuai.crm.settings.dao;

import com.zengshuai.crm.settings.domain.DicValue;

import java.util.List;

public interface DicValueDao {
    List<DicValue> getDicValue(String code);
}
