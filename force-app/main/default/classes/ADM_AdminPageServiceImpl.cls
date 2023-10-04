/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve Admin Pages.
 *
 * @author Daniel Peter (Robots & Pencils)
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Daniel Peter        29 June 2020        Created.
 *****************************************************************************************************/
public with sharing class ADM_AdminPageServiceImpl {

    private final ADM_AdminPageManager adminPageManager = ADM_AdminPageManager.getInstance();

    /**
     * This method retrieves admin pages
     */
    public List<Adm.AdminPage> getActiveAdminPages() {

        System.debug(LoggingLevel.FINEST, 'getActiveAdminPages() - enter');

        List<Adm.AdminPage> activeAdminPageList = new List<Adm.AdminPage>();

        try {
            // Retrieve admin page information from admin page manager.
            activeAdminPageList = adminPageManager.getActiveAdminPages();
            System.debug(LoggingLevel.INFO, 'getActiveAdminPages() : Retrieved active admin pages');
        } catch (Exception e) {

            System.debug(LoggingLevel.ERROR, 'getActiveAdminPages() : Failed to retrieve admin pages. Error= ' + e.getStackTraceString());
            throw e;
        } finally {
            System.debug(LoggingLevel.DEBUG, 'getActiveAdminPages() - exit; activeAdminPageList.size()= ' + activeAdminPageList.size());
        }

        return activeAdminPageList;
    }
}