package com.zengshuai.crm.settings.service.impl;

import com.zengshuai.crm.settings.dao.DicTypeDao;
import com.zengshuai.crm.settings.dao.DicValueDao;
import com.zengshuai.crm.settings.domain.DicType;
import com.zengshuai.crm.settings.domain.DicValue;
import com.zengshuai.crm.settings.service.DicService;
import com.zengshuai.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/7/4_11:30 
*/
public class DicServiceImpl implements DicService {
    private DicTypeDao dtd = SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    private DicValueDao dvd = SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);
    @Override
    public Map<String, List<DicValue>> getDicInfo() {
        Map<String, List<DicValue>> map = new HashMap<>();
        List<DicType> dicTypes = dtd.getDicTypes();
        for(DicType dicType:dicTypes){
            String typeCode = dicType.getCode();
            List<DicValue> vList = dvd.getDicValue(typeCode);
            map.put(dicType.getCode()+"List",vList);
        }
        return map;
    }
}
