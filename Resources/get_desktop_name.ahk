#Requires AutoHotkey v2

class VirtualDesktops
{
    static CLSID_ImmersiveShell                := '{C2F03A33-21F5-47FA-B4BB-156362A2F239}'
         , CLSID_VirtualDesktopManager         := '{AA509086-5CA9-4C25-8F95-589D3C07B48A}'
         , CLSID_VirtualDesktopManagerInternal := '{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}'
         , IID_IUnknown                        := '{00000000-0000-0000-C000-000000000046}'
         , IID_IServiceProvider                := '{6D5140C1-7436-11CE-8034-00AA006009FA}'
         , IID_IVirtualDesktopManagerInternal  := '{F31574D6-B682-4CDC-BD56-1827860ABEC6}'
         , IID_IVirtualDesktop                 := '{FF72FFDD-BE7E-43FC-9C03-AD81681E88E4}'
         , IID_IVirtualDesktop2                := '{31EBDE3F-6EC3-4CBD-B9FB-0EF6D09B41F4}'

         , build := StrSplit(A_OSVersion, '.')[3]

    static _CheckDescendantsMetod(name, &res?, params*) {
        if this.build < 19041 && this.build_17763.HasOwnProp(name)
            res := this.build_22000.%name%(params*)
        if this.build = 20348 && this.build_20348_server.HasOwnProp(name)
            res := this.build_20348_server%name%(params*)
        else if this.build = 22000 && this.build_22000.HasOwnProp(name)
            res := this.build_22000.%name%(params*)
        else if this.build > 22000 && this.build_22621.HasOwnProp(name)
            res := this.build_22621.%name%(params*)
    }

    static GetCurrentVirtualDesktopName() {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?)
        if IsSet(res)
            return res

        IVirtualDesktop := this.GetCurrentDesktop()
        if ((name := this.GetVirtualDesktopName(IVirtualDesktop)) = '')
            name := 'Desktop ' . this.GetIVirtualDesktopIndex(IVirtualDesktop)
        return name
    }

    static GetVirtualDesktopNames() {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?)
        if IsSet(res)
            return res

        IVirtualDesktopManagerInternal := this.GetIVirtualDesktopManagerInternal()
        ComCall(GetDesktops := 7, IVirtualDesktopManagerInternal, 'PtrP', &ptr := 0)
        IObjectArray := ComValue(VT_UNKNOWN := 0xD, ptr)
        ComCall(GetCount := 3, IObjectArray, 'UIntP', &count := 0)
        names := []
        Loop count {
            IVirtualDesktop := this.GetIVirtualDesktopFromIObjectArray(IObjectArray, A_Index - 1)
            name := this.GetVirtualDesktopName(IVirtualDesktop)
            (name = '' && name := 'Desktop ' . A_Index)
            names.Push(name)
        }
        return names
    }

    static GetCurrentDesktop() {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?)
        if IsSet(res)
            return res

        IVirtualDesktopManagerInternal := this.GetIVirtualDesktopManagerInternal()
        ComCall(GetCurrentDesktop := 6, IVirtualDesktopManagerInternal, 'PtrP', &ptr := 0)
        return IVirtualDesktop := ComValue(VT_UNKNOWN := 0xD, ptr)
    }

    static GetVirtualDesktopName(IVirtualDesktop) {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?, IVirtualDesktop)
        if IsSet(res)
            return res

        IVirtualDesktop2 := ComObjQuery(IVirtualDesktop, this.IID_IVirtualDesktop2)
        ComCall(GetName := 5, IVirtualDesktop2, 'PtrP', &hString := 0)
        if !hString
            return ''
        pBuf := DllCall('Combase\WindowsGetStringRawBuffer', 'Ptr', hString, 'UIntP', &len := 0, 'Ptr')
        DllCall('Combase\WindowsDeleteString', 'Ptr', hString)
        return StrGet(pBuf, len, 'UTF-16')
    }

    static GetIVirtualDesktopManagerInternal() {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?)
        if IsSet(res)
            return res

        ImmersiveShell := ComObject(this.CLSID_ImmersiveShell, this.IID_IUnknown)
        IServiceProvider := ComObject(this.CLSID_ImmersiveShell, this.IID_IServiceProvider)
        IVirtualDesktopManagerInternal := ComObjQuery( IServiceProvider, this.CLSID_VirtualDesktopManagerInternal
                                                                       , this.IID_IVirtualDesktopManagerInternal )
        return IVirtualDesktopManagerInternal
    }

    static GetIVirtualDesktopIndex(IVirtualDesktop) {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?, IVirtualDesktop)
        if IsSet(res)
            return res

        IVirtualDesktopManagerInternal := this.GetIVirtualDesktopManagerInternal()
        id := this.GetID(IVirtualDesktop)
        IObjectArray := this.GetDesktops(IVirtualDesktopManagerInternal)
        ComCall(GetCount := 3, IObjectArray, 'UIntP', &count := 0)
        idx := 0
        Loop count {
            IVirtualDesktop := this.GetIVirtualDesktopFromIObjectArray(IObjectArray, A_Index - 1)
            currentID := this.GetID(IVirtualDesktop)
        } until currentID = id && idx := A_Index
        return idx
    }

    static GetDesktops(IVirtualDesktopManagerInternal) {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?, IVirtualDesktopManagerInternal)
        if IsSet(res)
            return res

        ComCall(GetDesktops := 7, IVirtualDesktopManagerInternal, 'PtrP', &ptr := 0)
        return IObjectArray := ComValue(VT_UNKNOWN := 0xD, ptr)
    }

    static GetIVirtualDesktopFromIObjectArray(IObjectArray, n) {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?, IObjectArray, n)
        if IsSet(res)
            return res

        CLSID := Buffer(16, 0)
        DllCall('Ole32\CLSIDFromString', 'WStr', this.IID_IVirtualDesktop, 'Ptr', CLSID)
        ComCall(GatAt := 4, IObjectArray, 'UInt', n, 'Ptr', CLSID, 'PtrP', &ptr := 0)
        return IVirtualDesktop := ComValue(VT_UNKNOWN := 0xD, ptr)
    }

    static GetID(IVirtualDesktop) {
        this._CheckDescendantsMetod(StrSplit(A_ThisFunc, '.')[2], &res?, IVirtualDesktop)
        if IsSet(res)
            return res

        ComCall(GetId := 4, IVirtualDesktop, 'Ptr', GUID := Buffer(16, 0))
        VarSetStrCapacity(&sGuid, 78)
        DllCall('Ole32\StringFromGUID2', 'Ptr', GUID, 'WStr', sGuid, 'Int', 39)
        return sGuid
    }

    class build_17763 extends VirtualDesktops {
        static GetVirtualDesktopName(IVirtualDesktop) {
            return ''
        }
    }

    class build_20348_server extends VirtualDesktops
    {
        static IID_IVirtualDesktopManagerInternal := '{094AFE11-44F2-4BA0-976F-29A97E263EE0}'
             , IID_IVirtualDesktop                := '{62FDF88B-11CA-4AFB-8BD8-2296DFAE49E2}'

        static GetIVirtualDesktopManagerInternal() {
            ImmersiveShell := ComObject(this.CLSID_ImmersiveShell, this.IID_IUnknown)
            IServiceProvider := ComObject(this.CLSID_ImmersiveShell, this.IID_IServiceProvider)
            IVirtualDesktopManagerInternal := ComObjQuery( IServiceProvider, this.CLSID_VirtualDesktopManagerInternal
                                                                           , this.IID_IVirtualDesktopManagerInternal )
            return IVirtualDesktopManagerInternal
        }

        static GetIVirtualDesktopFromIObjectArray(IObjectArray, n) {
            CLSID := Buffer(16, 0)
            DllCall('Ole32\CLSIDFromString', 'WStr', this.IID_IVirtualDesktop, 'Ptr', CLSID)
            ComCall(GatAt := 4, IObjectArray, 'UInt', n, 'Ptr', CLSID, 'PtrP', &ptr := 0)
            return IVirtualDesktop := ComValue(VT_UNKNOWN := 0xD, ptr)
        }
    }

    class build_22000 extends VirtualDesktops
    {
        static IID_IVirtualDesktopManagerInternal := '{B2F925B9-5A0F-4D2E-9F4D-2B1507593C10}'
             , IID_IVirtualDesktop                := '{536D3495-B208-4CC9-AE26-DE8111275BF8}'

        static GetCurrentVirtualDesktopName() {
            IVirtualDesktop := this.GetCurrentDesktop()
            if ((name := this.GetVirtualDesktopName(IVirtualDesktop)) = '')
                name := 'Desktop ' . super.GetIVirtualDesktopIndex(IVirtualDesktop)
            return name
        }

        static GetVirtualDesktopName(IVirtualDesktop) {
            ComCall(GetName := 6, IVirtualDesktop, 'PtrP', &hString := 0)
            if !hString
                return ''
            pBuf := DllCall('Combase\WindowsGetStringRawBuffer', 'Ptr', hString, 'UIntP', &len := 0, 'Ptr')
            DllCall('Combase\WindowsDeleteString', 'Ptr', hString)
            return StrGet(pBuf, len, 'UTF-16')
        }

        static GetIVirtualDesktopManagerInternal() {
            ImmersiveShell := ComObject(this.CLSID_ImmersiveShell, this.IID_IUnknown)
            IServiceProvider := ComObject(this.CLSID_ImmersiveShell, this.IID_IServiceProvider)
            IVirtualDesktopManagerInternal := ComObjQuery( IServiceProvider, this.CLSID_VirtualDesktopManagerInternal
                                                                            , this.IID_IVirtualDesktopManagerInternal )
            return IVirtualDesktopManagerInternal
        }

        static GetDesktops(IVirtualDesktopManagerInternal) {
            ComCall(GetDesktops := 8, IVirtualDesktopManagerInternal, 'Ptr', 0, 'PtrP', &ptr := 0)
            return IObjectArray := ComValue(VT_UNKNOWN := 0xD, ptr)
        }

        static GetIVirtualDesktopFromIObjectArray(IObjectArray, n) {
            CLSID := Buffer(16, 0)
            DllCall('Ole32\CLSIDFromString', 'WStr', this.IID_IVirtualDesktop, 'Ptr', CLSID)
            ComCall(GatAt := 4, IObjectArray, 'UInt', n, 'Ptr', CLSID, 'PtrP', &ptr := 0)
            return IVirtualDesktop := ComValue(VT_UNKNOWN := 0xD, ptr)
        }

        static GetCurrentDesktop() {
            IVirtualDesktopManagerInternal := this.GetIVirtualDesktopManagerInternal()
            ComCall(GetCurrentDesktop := 6, IVirtualDesktopManagerInternal, 'Ptr', 0, 'PtrP', &ptr := 0)
            return IVirtualDesktop := ComValue(VT_UNKNOWN := 0xD, ptr)
        }
    }

    class build_22621 extends VirtualDesktops
    {
        static GetCurrentVirtualDesktopName() {
            return super.build_22000.GetCurrentVirtualDesktopName()
        }

        static GetVirtualDesktopName(IVirtualDesktop) {
            return super.build_22000.GetVirtualDesktopName(IVirtualDesktop)
        }

        static GetIVirtualDesktopManagerInternal() {
            return super.build_22000.GetIVirtualDesktopManagerInternal()
        }

        static GetDesktops(IVirtualDesktopManagerInternal) {
            ComCall(GetDesktops := 8, IVirtualDesktopManagerInternal, 'Ptr', 0, 'PtrP', &ptr := 0)
            return IObjectArray := ComValue(VT_UNKNOWN := 0xD, ptr)
        }

        static GetIVirtualDesktopFromIObjectArray(IObjectArray, n) {
            return super.build_22000.GetIVirtualDesktopFromIObjectArray(IObjectArray, n)
        }

        static GetCurrentDesktop() {
            return super.build_22000.GetCurrentDesktop()
        }
    }
}