package com.zengshuai.crm.settings.domain;
/**
*function:  -
*project:   crm
*author:    cengs
*version:   1.0 2019/7/4_10:17 
*/
public class DicType {
    private String code;
    private String name;
    private String description;

    public DicType() {
    }

    public DicType(String code, String name, String description) {
        this.code = code;
        this.name = name;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
