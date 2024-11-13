//
//  SSOEnums.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 24/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#ifndef SSOEnums_h
#define SSOEnums_h

/**
 This specifies the Build type.
 */
typedef NS_ENUM(NSInteger, SSOBuildType)
{
    /**
     *  Points to localzoho server and SSO OneAuth Development setup. accounts.localzoho.com. You need to be connected to Zoho-Handhelds or ZohoCorp wifi to work in this mode.
     */
    Local_SSO_Development = 0,
    /**
     *  Points to localzoho server and SSO OneAuth MDM setup. accounts.localzoho.com. You need to be connected to Zoho-Handhelds or ZohoCorp wifi to work in this mode.
     */
    Local_SSO_Mdm,
    /**
     *  Points to localzoho Development server and SSO OneAuth Development setup. accounts-dev.localzoho.com. You need to be connected to Zoho-Handhelds or ZohoCorp wifi to work in this mode.
     */
    LocalDev_SSO_Development,
    /**
     *  Points to IDC server and SSO OneAuth Development/App Store setup. accounts.zoho.com.
     */
    Live_SSO,
    /**
     *  Points to IDC server and SSO OneAuth MDM App. accounts.zoho.com.
     */
    Live_SSO_Mdm,
    /**
     *  Points to accounts csez server and SSO OneAuth Development/App Store setup. accounts.csez.zohocorpin.com.
     */
    CSEZ_SSO_Dev,
    /**
     *  Points to accounts csez server and SSO OneAuth MDM App. accounts.csez.zohocorpin.com.
     */
    CSEZ_SSO_MDM,
    /**
     *  Points to preaccounts server and SSO OneAuth Development/App Store setup. preaccounts.zoho.com.
     */
    PRE_SSO_Dev,
    /**
     *  Points to preaccounts server and SSO OneAuth MDM App. preaccounts.zoho.com.
     */
    PRE_SSO_MDM,
    /**
     *  Points to iaccounts server and SSO OneAuth Development/App Store setup. iaccounts.zoho.com.
     */
    iAccounts_SSO_Dev,
    /**
     *  Points to iaccounts server and SSO OneAuth MDM App. iaccounts.zoho.com.
     */
    iAccounts_SSO_MDM,
    /**
     *  Points to accounts.charmtracker.com.
     */
    CHARM_LIVE,
    /**
     *  Points to preaccounts.charmtracker.com.
     */
    CHARM_PRE,
    
};

#endif /* SSOEnums_h */
