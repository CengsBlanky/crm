package com.zengshuai.crm.web.listener;

import com.zengshuai.crm.settings.domain.DicValue;
import com.zengshuai.crm.settings.service.DicService;
import com.zengshuai.crm.settings.service.impl.DicServiceImpl;
import com.zengshuai.crm.utils.ServiceFactory;


import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/7/4_11:22 
*/
public class SysInitListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent event) {
        DicService service = (DicService) ServiceFactory.getService(new DicServiceImpl());
        Map<String, List<DicValue>> map = service.getDicInfo();
        ServletContext application = event.getServletContext();
        System.out.println("全局作用域对象建立");
        System.out.println("服务器开始缓存数据字典");
        Set<String> set = map.keySet();
        for(String key:set){
            application.setAttribute(key,map.get(key));
            System.out.println(key+"类型字典添加...");
        }
        System.out.println("服务器缓存数据字典结束");

        //阶段与可能性之间的一一对应关系建立
        System.out.println("开始缓存阶段与可能性对应关系...");
        Map<String,String> spMap = new HashMap<>();
        ResourceBundle bundle = ResourceBundle.getBundle("Stage2Possibility");
        Enumeration<String> enumKey = bundle.getKeys();
        while(enumKey.hasMoreElements()){
            String stage = enumKey.nextElement();
            String possibility = bundle.getString(stage);
            spMap.put(stage,possibility);
        }
        application.setAttribute("spMap",spMap);
        System.out.println("缓存阶段与可能性对应关系结束");
    }
}
