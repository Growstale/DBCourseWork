﻿#pragma checksum "..\..\OrganizerRegistration.xaml" "{8829d00f-11b8-4213-878b-770e8597ac16}" "3F7954B9BBC30F4FF902941FC7BBB0F8E1E7B5ACEBB38779D71472970A4D3340"
//------------------------------------------------------------------------------
// <auto-generated>
//     Этот код создан программой.
//     Исполняемая версия:4.0.30319.42000
//
//     Изменения в этом файле могут привести к неправильной работе и будут потеряны в случае
//     повторной генерации кода.
// </auto-generated>
//------------------------------------------------------------------------------

using CourseWork;
using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Media.TextFormatting;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Shell;


namespace CourseWork {
    
    
    /// <summary>
    /// OrganizerRegistration
    /// </summary>
    public partial class OrganizerRegistration : System.Windows.Window, System.Windows.Markup.IComponentConnector {
        
        
        #line 13 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox CompanyNameForRegistration_TextBox;
        
        #line default
        #line hidden
        
        
        #line 15 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox PasswordForRegistration_TextBox;
        
        #line default
        #line hidden
        
        
        #line 17 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button Registration_Button;
        
        #line default
        #line hidden
        
        
        #line 18 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button GoToAuthorizationn_Button;
        
        #line default
        #line hidden
        
        
        #line 19 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox FirstNameForRegistration_TextBox;
        
        #line default
        #line hidden
        
        
        #line 21 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox LastNameForRegistration_TextBox;
        
        #line default
        #line hidden
        
        
        #line 23 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox EmailForRegistration_TextBox;
        
        #line default
        #line hidden
        
        
        #line 25 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.TextBox PhoneForRegistration_TextBox;
        
        #line default
        #line hidden
        
        
        #line 27 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button GoToRegistration_Button_User;
        
        #line default
        #line hidden
        
        
        #line 28 "..\..\OrganizerRegistration.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button GoToRegistration_Button_Manager;
        
        #line default
        #line hidden
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Uri resourceLocater = new System.Uri("/CourseWork;component/organizerregistration.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\OrganizerRegistration.xaml"
            System.Windows.Application.LoadComponent(this, resourceLocater);
            
            #line default
            #line hidden
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        void System.Windows.Markup.IComponentConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 1:
            this.CompanyNameForRegistration_TextBox = ((System.Windows.Controls.TextBox)(target));
            return;
            case 2:
            this.PasswordForRegistration_TextBox = ((System.Windows.Controls.TextBox)(target));
            return;
            case 3:
            this.Registration_Button = ((System.Windows.Controls.Button)(target));
            
            #line 17 "..\..\OrganizerRegistration.xaml"
            this.Registration_Button.Click += new System.Windows.RoutedEventHandler(this.CallRegisterOrganizerProcedure);
            
            #line default
            #line hidden
            return;
            case 4:
            this.GoToAuthorizationn_Button = ((System.Windows.Controls.Button)(target));
            
            #line 18 "..\..\OrganizerRegistration.xaml"
            this.GoToAuthorizationn_Button.Click += new System.Windows.RoutedEventHandler(this.OpenAuthorizationUser);
            
            #line default
            #line hidden
            return;
            case 5:
            this.FirstNameForRegistration_TextBox = ((System.Windows.Controls.TextBox)(target));
            return;
            case 6:
            this.LastNameForRegistration_TextBox = ((System.Windows.Controls.TextBox)(target));
            return;
            case 7:
            this.EmailForRegistration_TextBox = ((System.Windows.Controls.TextBox)(target));
            return;
            case 8:
            this.PhoneForRegistration_TextBox = ((System.Windows.Controls.TextBox)(target));
            return;
            case 9:
            this.GoToRegistration_Button_User = ((System.Windows.Controls.Button)(target));
            
            #line 27 "..\..\OrganizerRegistration.xaml"
            this.GoToRegistration_Button_User.Click += new System.Windows.RoutedEventHandler(this.OpenRegistrationUser);
            
            #line default
            #line hidden
            return;
            case 10:
            this.GoToRegistration_Button_Manager = ((System.Windows.Controls.Button)(target));
            
            #line 28 "..\..\OrganizerRegistration.xaml"
            this.GoToRegistration_Button_Manager.Click += new System.Windows.RoutedEventHandler(this.OpenRegistrationManager);
            
            #line default
            #line hidden
            return;
            }
            this._contentLoaded = true;
        }
    }
}

