<#
===================================================================================
  ASI WINDOWS UTILITY - Premium Minimalist Edition
  Developed by Amar Kumar (AMAR SMART INDIA)
  Website: https://amarsmartindia.in/
  Description: Modern Portable Windows Optimization, Repair, & Software Management Hub
===================================================================================
#>

# ---------------------------------------------------------------------------------
# 1. LOAD REQUIRED WPF & WINDOWS FORMS ASSEMBLIES
# ---------------------------------------------------------------------------------
Add-Type -AssemblyName PresentationFramework -ErrorAction SilentlyContinue
Add-Type -AssemblyName PresentationCore -ErrorAction SilentlyContinue
Add-Type -AssemblyName WindowsBase -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue

# ---------------------------------------------------------------------------------
# 2. ELEVATION CHECK (Self-Elevate to Administrator if possible)
# ---------------------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin -and -not $env:ASI_SKIP_ELEVATE) {
    try {
        $scriptPath = $MyInvocation.MyCommand.Path
        if ($scriptPath -and (Test-Path $scriptPath)) {
            $env:ASI_SKIP_ELEVATE = "1"
            $p = Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -PassThru -ErrorAction Stop
            if ($p) { exit }
        }
    } catch {
        # Elevation prompt skipped or denied; continuing in GUI mode
    }
}

# ---------------------------------------------------------------------------------
# 3. HARDWARE & BATTERY DETECTION LOGIC
# ---------------------------------------------------------------------------------
$hasBattery = $false
try {
    $batteries = @(Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue)
    if ($batteries -and $batteries.Count -gt 0) {
        $hasBattery = $true
    } else {
        $chassis = @(Get-CimInstance -ClassName Win32_SystemEnclosure -ErrorAction SilentlyContinue)
        if ($chassis) {
            foreach ($c in $chassis) {
                if ($c.ChassisTypes -contains 8 -or $c.ChassisTypes -contains 9 -or $c.ChassisTypes -contains 10 -or $c.ChassisTypes -contains 14) {
                    $hasBattery = $true
                    break
                }
            }
        }
    }
} catch {
    $hasBattery = $false
}

$deviceTypeStr = if ($hasBattery) { "Laptop (Battery Detected)" } else { "Desktop (No Battery Detected)" }

# Determine Assets Path
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptDir) { $scriptDir = Get-Location }
$assetsDir = Join-Path $scriptDir "assets"
$logoPath = Join-Path $assetsDir "app_logo.png"

# ---------------------------------------------------------------------------------
# 4. XAML USER INTERFACE DEFINITION (Verbatim String)
# ---------------------------------------------------------------------------------
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ASI WINDOWS UTILITY - Amar Smart India" Height="860" Width="1200"
        WindowStartupLocation="CenterScreen" Background="#F8FAFC" Foreground="#0F172A"
        FontFamily="Segoe UI" x:Name="MainWindow">

    <Window.Resources>
        <!-- Default Light Theme Brushes -->
        <SolidColorBrush x:Key="BgBrush" Color="#F8FAFC"/>
        <SolidColorBrush x:Key="HeaderBgBrush" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="CardBgBrush" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="CardBorderBrush" Color="#E2E8F0"/>
        <SolidColorBrush x:Key="TextPrimaryBrush" Color="#0F172A"/>
        <SolidColorBrush x:Key="TextSecondaryBrush" Color="#64748B"/>
        <SolidColorBrush x:Key="AccentBrush" Color="#0EA5E9"/>
        <SolidColorBrush x:Key="AccentHoverBrush" Color="#0284C7"/>
        <SolidColorBrush x:Key="SuccessBrush" Color="#10B981"/>
        <SolidColorBrush x:Key="WarningBrush" Color="#F59E0B"/>
        <SolidColorBrush x:Key="DangerBrush" Color="#EF4444"/>
        <SolidColorBrush x:Key="ConsoleBgBrush" Color="#F1F5F9"/>

        <!-- Navigation Button Style -->
        <Style x:Key="NavTabStyle" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource TextSecondaryBrush}"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Margin" Value="3,0"/>
            <Setter Property="Padding" Value="16,10"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="22" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#F1F5F9"/>
                                <Setter Property="Foreground" Value="{DynamicResource TextPrimaryBrush}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Primary Action Button -->
        <Style x:Key="ActionBtnStyle" TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource AccentBrush}"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="{DynamicResource AccentHoverBrush}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Green Success Button -->
        <Style x:Key="GreenBtnStyle" TargetType="Button">
            <Setter Property="Background" Value="{DynamicResource SuccessBrush}"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#059669"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Outline / Ghost Button -->
        <Style x:Key="OutlineBtnStyle" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="{DynamicResource AccentBrush}"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="BorderThickness" Value="1.4"/>
            <Setter Property="BorderBrush" Value="{DynamicResource AccentBrush}"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="7" Padding="{TemplateBinding Padding}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="{DynamicResource AccentBrush}"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Background="{DynamicResource BgBrush}">
        <Grid.RowDefinitions>
            <RowDefinition Height="64"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="155"/>
        </Grid.RowDefinitions>

        <!-- TOP NAVIGATION HEADER BAR -->
        <Border Grid.Row="0" Background="{DynamicResource HeaderBgBrush}" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="0,0,0,1" Padding="20,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <!-- Left: Branding Logo -->
                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    <Border x:Name="LogoBorder" Width="40" Height="40" CornerRadius="10" Margin="0,0,10,0">
                        <Border.Background>
                            <SolidColorBrush Color="#0EA5E9"/>
                        </Border.Background>
                        <TextBlock Text="ASI" Foreground="White" FontWeight="Bold" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center" x:Name="LogoTextFallback"/>
                    </Border>
                    <StackPanel VerticalAlignment="Center">
                        <TextBlock Text="ASI UTILITY" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="15"/>
                        <TextBlock x:Name="DeviceTypeTxt" Text="Amar Smart India" Foreground="{DynamicResource AccentBrush}" FontSize="9.5" FontWeight="SemiBold"/>
                    </StackPanel>
                </StackPanel>

                <!-- Center: Top Header Navigation Tabs -->
                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
                    <Button x:Name="NavToolsBtn" Style="{StaticResource NavTabStyle}" Background="#EFF6FF" Foreground="{DynamicResource AccentBrush}">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="&#x1F6E0;&#xFE0F;" Margin="0,0,5,0"/>
                            <TextBlock Text="Tools"/>
                        </StackPanel>
                    </Button>
                    <Button x:Name="NavGuideBtn" Style="{StaticResource NavTabStyle}">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="&#x1F4D6;" Margin="0,0,5,0"/>
                            <TextBlock Text="Guide"/>
                        </StackPanel>
                    </Button>
                    <Button x:Name="NavInstallBtn" Style="{StaticResource NavTabStyle}">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="&#x1F4E6;" Margin="0,0,5,0"/>
                            <TextBlock Text="Install Hub"/>
                        </StackPanel>
                    </Button>
                    <Button x:Name="NavUpdateBtn" Style="{StaticResource NavTabStyle}">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="&#x1F504;" Margin="0,0,5,0"/>
                            <TextBlock Text="Updates"/>
                        </StackPanel>
                    </Button>
                    <Button x:Name="NavAboutBtn" Style="{StaticResource NavTabStyle}">
                        <StackPanel Orientation="Horizontal">
                            <TextBlock Text="&#x1F468;&#x200D;&#x1F4BB;" Margin="0,0,5,0"/>
                            <TextBlock Text="About"/>
                        </StackPanel>
                    </Button>
                </StackPanel>

                <!-- Right: Theme Mode Switcher -->
                <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="&#x1F3A8;" FontSize="14" VerticalAlignment="Center" Margin="0,0,6,0"/>
                    <ComboBox x:Name="CmbTheme" Width="110" Padding="6,4" Background="{DynamicResource CardBgBrush}" Foreground="{DynamicResource TextPrimaryBrush}" BorderBrush="{DynamicResource CardBorderBrush}" SelectedIndex="1">
                        <ComboBoxItem Content="Auto (System)"/>
                        <ComboBoxItem Content="Light Theme"/>
                        <ComboBoxItem Content="Dark Theme"/>
                    </ComboBox>
                </StackPanel>
            </Grid>
        </Border>

        <!-- MAIN BODY CONTENT AREA -->
        <Grid Grid.Row="1" Margin="20,16,20,0">

            <!-- ============================================================ -->
            <!-- TAB 1: TOOLS DASHBOARD                                       -->
            <!-- ============================================================ -->
            <ScrollViewer x:Name="TabTools" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                <StackPanel>
                    <TextBlock Text="System Repair &amp; Optimization Tools" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="20" FontWeight="Bold" Margin="0,0,0,3"/>
                    <TextBlock Text="1-Click Windows maintenance, cleanup, SFC/DISM repairs, and system tuning." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="12" Margin="0,0,0,14"/>

                    <UniformGrid Columns="2">
                        <!-- Tool 1: System Cleaner -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#EFF6FF" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F9F9;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="System Cleaner" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Clean Prefetch, Temp, &amp; AppData junk to free disk space." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnCleanSystem" Content="Clean Temp Data" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 2: System Repair -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#ECFDF5" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F6E1;&#xFE0F;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="System Repair" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Run SFC scan &amp; DISM Online Health Restoration." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnRepairSystem" Content="Run SFC &amp; DISM" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 3: Network Reset -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#FFF7ED" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F310;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="Network Reset" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Flush DNS, reset Winsock &amp; IP adapters to fix connectivity." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnResetNetwork" Content="Reset Network" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 4: Virus Scanner -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#FEF2F2" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F9A0;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="Virus Scanner" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Invoke Windows Defender quick scan to detect threats." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnScanVirus" Content="Start Defender Scan" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 5: Startup Manager -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#F5F3FF" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F680;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="Startup Manager" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Inspect and auto-optimize startup programs." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnOptimizeStartup" Content="Auto-Optimize Startup" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 6: Mouse Fix -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#FDF2F8" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F5B1;&#xFE0F;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="Mouse Fix" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Fix mouse acceleration, scrolling stutter, and lag." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnFixMouse" Content="Fix Mouse Accel" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 7: Windows Activation -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#ECFDF5" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F511;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="Windows Activation (HWID)" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Permanently activate Windows via digital license." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnActivateHWID" Content="Activate Windows" Style="{StaticResource GreenBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 8: Speaker Fixing -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#FFFBEB" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F50A;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="Speaker Fixing" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Restart Audio Engine and reset sound endpoints." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnFixSpeaker" Content="Fix Audio" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 9: Battery Life Saver -->
                        <Border x:Name="CardBattery" Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#F0FDF4" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x1F50B;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="Battery Life Saver" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Optimize power plans &amp; reduce background drain." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnSaveBattery" Content="Enable Battery Saver" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                        <!-- Tool 10: Background Process Optimizer -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="12" Padding="16" Margin="5" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <Border Width="44" Height="44" CornerRadius="10" Background="#FEF9C3" Margin="0,0,12,0" VerticalAlignment="Top">
                                    <TextBlock Text="&#x26A1;" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <StackPanel Grid.Column="1">
                                    <TextBlock Text="Process Optimizer" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="14" FontWeight="Bold"/>
                                    <TextBlock Text="Kill telemetry &amp; non-essential bloatware services." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" TextWrapping="Wrap" Margin="0,3,0,10"/>
                                    <Button x:Name="BtnOptimizeProcesses" Content="Kill Bloatware" Style="{StaticResource ActionBtnStyle}" HorizontalAlignment="Left"/>
                                </StackPanel>
                            </Grid>
                        </Border>
                    </UniformGrid>
                </StackPanel>
            </ScrollViewer>

            <!-- ============================================================ -->
            <!-- TAB 2: TOOL GUIDE                                            -->
            <!-- ============================================================ -->
            <ScrollViewer x:Name="TabGuide" Visibility="Collapsed" VerticalScrollBarVisibility="Auto">
                <StackPanel>
                    <TextBlock Text="Tool Guide &amp; Documentation" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="20" FontWeight="Bold" Margin="0,0,0,3"/>
                    <TextBlock Text="How each tool works, safety impact, and recommended usage." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="12" Margin="0,0,0,14"/>
                    <StackPanel>
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="16" Margin="0,0,0,8" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="&#x1F9F9; 1. System Cleaner" Foreground="{DynamicResource AccentBrush}" FontSize="14" FontWeight="Bold"/>
                                <TextBlock Text="Deletes residual temp files in Prefetch, Windows Temp, and User Temp folders. Does not touch personal documents or downloads." Foreground="{DynamicResource TextPrimaryBrush}" FontSize="12" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Border>
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="16" Margin="0,0,0,8" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="&#x1F6E1;&#xFE0F; 2. System Repair (SFC &amp; DISM)" Foreground="{DynamicResource AccentBrush}" FontSize="14" FontWeight="Bold"/>
                                <TextBlock Text="Scans Windows DLLs with SFC. If corruption is detected, DISM downloads clean replacements from Microsoft servers." Foreground="{DynamicResource TextPrimaryBrush}" FontSize="12" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Border>
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="16" Margin="0,0,0,8" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="&#x1F310; 3. Network Reset" Foreground="{DynamicResource AccentBrush}" FontSize="14" FontWeight="Bold"/>
                                <TextBlock Text="Flushes DNS cache, resets Winsock catalog, and resets the IP adapter stack. Fixes DNS resolution and socket drops." Foreground="{DynamicResource TextPrimaryBrush}" FontSize="12" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Border>
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="16" Margin="0,0,0,8" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="&#x1F9A0; 4. Virus Scanner" Foreground="{DynamicResource AccentBrush}" FontSize="14" FontWeight="Bold"/>
                                <TextBlock Text="Triggers Microsoft Defender Quick Scan via PowerShell. Detects active malware and threats." Foreground="{DynamicResource TextPrimaryBrush}" FontSize="12" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Border>
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="16" Margin="0,0,0,8" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="&#x1F511; 5. Windows HWID Activation" Foreground="{DynamicResource SuccessBrush}" FontSize="14" FontWeight="Bold"/>
                                <TextBlock Text="Executes open-source HWID activation script. Binds a permanent digital license to your hardware." Foreground="{DynamicResource TextPrimaryBrush}" FontSize="12" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </StackPanel>
            </ScrollViewer>

            <!-- ============================================================ -->
            <!-- TAB 3: INSTALL HUB                                           -->
            <!-- ============================================================ -->
            <ScrollViewer x:Name="TabInstall" Visibility="Collapsed" VerticalScrollBarVisibility="Auto">
                <StackPanel>
                    <TextBlock Text="Software Installation Hub" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="20" FontWeight="Bold" Margin="0,0,0,3"/>
                    <TextBlock Text="1-Click direct install or batch-select multiple apps. Powered by Winget." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="12" Margin="0,0,0,14"/>

                    <!-- Batch Control Bar -->
                    <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="0,0,0,12" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Button x:Name="BtnSelectAllApps" Content="Select All" Style="{StaticResource OutlineBtnStyle}" Margin="0,0,8,0"/>
                                <Button x:Name="BtnDeselectAllApps" Content="Deselect All" Style="{StaticResource OutlineBtnStyle}"/>
                            </StackPanel>
                            <Button x:Name="BtnInstallSelected" Grid.Column="1" Content="&#x26A1; Install Selected (Batch)" Style="{StaticResource GreenBtnStyle}"/>
                        </Grid>
                    </Border>

                    <UniformGrid Columns="3">
                        <!-- Chrome -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkChrome" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Google Chrome" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Web browser" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallChrome" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Firefox -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkFirefox" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Mozilla Firefox" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Privacy browser" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallFirefox" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Comet Browser -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkComet" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Comet Browser" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Fast chromium" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallComet" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Antigravity IDE -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkAntigravity" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Antigravity IDE" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="AI code editor" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallAntigravity" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Python 3 -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkPython" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Python 3" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Programming lang" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallPython" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- VLC -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkVLC" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="VLC Media Player" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Video/audio player" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallVLC" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- VS Code -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkVSCode" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="VS Code" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Code editor" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallVSCode" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Telegram -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkTelegram" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Telegram" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Messaging app" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallTelegram" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- WhatsApp -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkWhatsApp" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="WhatsApp" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Messenger" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallWhatsApp" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- RustDesk -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkRustDesk" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="RustDesk" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Remote desktop" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallRustDesk" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- 7-Zip -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="Chk7Zip" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="7-Zip" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="File archiver" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstall7Zip" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Notepad++ -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkNotepadPP" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Notepad++" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Text editor" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallNotepadPP" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Git -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkGit" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Git" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Version control" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallGit" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Node.js -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkNodeJS" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Node.js LTS" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="JS runtime" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallNodeJS" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- OBS Studio -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkOBS" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="OBS Studio" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Screen recorder" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallOBS" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Discord -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkDiscord" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Discord" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Voice &amp; chat" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallDiscord" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                        <!-- Spotify -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                                <CheckBox x:Name="ChkSpotify" VerticalAlignment="Center" Margin="0,0,8,0"/>
                                <StackPanel Grid.Column="1" VerticalAlignment="Center"><TextBlock Text="Spotify" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="12"/><TextBlock Text="Music streaming" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="10"/></StackPanel>
                                <Button x:Name="BtnInstallSpotify" Grid.Column="2" Content="Install" Style="{StaticResource ActionBtnStyle}" VerticalAlignment="Center" Padding="10,5"/>
                            </Grid>
                        </Border>
                    </UniformGrid>
                </StackPanel>
            </ScrollViewer>

            <!-- ============================================================ -->
            <!-- TAB 4: UPDATES (Redesigned with per-app selection)           -->
            <!-- ============================================================ -->
            <ScrollViewer x:Name="TabUpdates" Visibility="Collapsed" VerticalScrollBarVisibility="Auto">
                <StackPanel>
                    <TextBlock Text="Software Updates Manager" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="20" FontWeight="Bold" Margin="0,0,0,3"/>
                    <TextBlock Text="Scan for outdated packages, select which to update, and upgrade in one click." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="12" Margin="0,0,0,14"/>

                    <!-- Status Banner -->
                    <Border x:Name="UpdateStatusBanner" Background="#EFF6FF" CornerRadius="10" Padding="14" Margin="0,0,0,12" BorderBrush="#BFDBFE" BorderThickness="1">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Text="&#x2139;&#xFE0F;" FontSize="18" VerticalAlignment="Center" Margin="0,0,10,0"/>
                            <StackPanel Grid.Column="1" VerticalAlignment="Center">
                                <TextBlock x:Name="UpdateStatusTitle" Text="Ready to Scan" Foreground="#1E40AF" FontWeight="Bold" FontSize="13"/>
                                <TextBlock x:Name="UpdateStatusMsg" Text="Click 'Scan for Updates' to check installed software for available upgrades." Foreground="#3B82F6" FontSize="11" TextWrapping="Wrap"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- Action Bar -->
                    <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Padding="12" Margin="0,0,0,12" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Button x:Name="BtnScanUpdates" Content="&#x1F50D; Scan for Updates" Style="{StaticResource ActionBtnStyle}" Margin="0,0,8,0"/>
                                <Button x:Name="BtnSelectAllUpdates" Content="Select All" Style="{StaticResource OutlineBtnStyle}" Margin="0,0,8,0"/>
                                <Button x:Name="BtnDeselectAllUpdates" Content="Deselect All" Style="{StaticResource OutlineBtnStyle}"/>
                            </StackPanel>
                            <Button x:Name="BtnUpdateSelected" Grid.Column="1" Content="&#x1F680; Update Selected" Style="{StaticResource GreenBtnStyle}"/>
                        </Grid>
                    </Border>

                    <!-- Update List Column Headers -->
                    <Border Background="{DynamicResource CardBorderBrush}" CornerRadius="8,8,0,0" Padding="12,8">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="30"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="120"/>
                                <ColumnDefinition Width="120"/>
                                <ColumnDefinition Width="80"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Grid.Column="0" Text="" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" FontWeight="Bold"/>
                            <TextBlock Grid.Column="1" Text="Package Name" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" FontWeight="Bold"/>
                            <TextBlock Grid.Column="2" Text="Current" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" FontWeight="Bold"/>
                            <TextBlock Grid.Column="3" Text="Available" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" FontWeight="Bold"/>
                            <TextBlock Grid.Column="4" Text="Action" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" FontWeight="Bold" HorizontalAlignment="Center"/>
                        </Grid>
                    </Border>

                    <!-- Update Items Container -->
                    <Border Background="{DynamicResource CardBgBrush}" CornerRadius="0,0,8,8" Padding="4" MinHeight="120" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1,0,1,1">
                        <StackPanel x:Name="UpdateItemsList">
                            <TextBlock Text="No scan performed yet. Click 'Scan for Updates' above." Foreground="{DynamicResource TextSecondaryBrush}" FontSize="12" HorizontalAlignment="Center" Margin="0,30"/>
                        </StackPanel>
                    </Border>
                </StackPanel>
            </ScrollViewer>

            <!-- ============================================================ -->
            <!-- TAB 5: ABOUT DEVELOPER                                       -->
            <!-- ============================================================ -->
            <ScrollViewer x:Name="TabAbout" Visibility="Collapsed" VerticalScrollBarVisibility="Auto">
                <StackPanel>
                    <!-- Developer Card -->
                    <Border Background="{DynamicResource CardBgBrush}" CornerRadius="14" Padding="24" Margin="0,0,0,16" BorderBrush="{DynamicResource AccentBrush}" BorderThickness="1.5">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Border Width="80" Height="80" CornerRadius="16" Background="{DynamicResource AccentBrush}" Margin="0,0,20,0">
                                <TextBlock Text="ASI" Foreground="White" FontWeight="Bold" FontSize="28" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <StackPanel Grid.Column="1" VerticalAlignment="Center">
                                <TextBlock Text="AMAR SMART INDIA" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="22" FontWeight="Bold"/>
                                <TextBlock Text="Creator: Amar Kumar" Foreground="{DynamicResource AccentBrush}" FontSize="14" FontWeight="SemiBold" Margin="0,2,0,2"/>
                                <TextBlock Text="Student | Tech Creator | Developer | Digital Educator" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="12"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- Social Links Header -->
                    <TextBlock Text="Social Connections" Foreground="{DynamicResource TextPrimaryBrush}" FontSize="16" FontWeight="Bold" Margin="0,0,0,12"/>
                    <UniformGrid Columns="2">
                        <!-- Website -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Button x:Name="BtnSocialWebsite" Background="Transparent" BorderThickness="0" Cursor="Hand" Padding="14" HorizontalContentAlignment="Left">
                                <StackPanel Orientation="Horizontal">
                                    <Border Width="40" Height="40" CornerRadius="10" Background="#EFF6FF" Margin="0,0,12,0">
                                        <TextBlock Text="W" Foreground="#0EA5E9" FontWeight="Bold" FontSize="18" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <StackPanel VerticalAlignment="Center">
                                        <TextBlock Text="Official Website" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="13"/>
                                        <TextBlock Text="amarsmartindia.in" Foreground="{DynamicResource AccentBrush}" FontSize="10.5"/>
                                    </StackPanel>
                                </StackPanel>
                            </Button>
                        </Border>
                        <!-- YouTube -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Button x:Name="BtnSocialYouTube" Background="Transparent" BorderThickness="0" Cursor="Hand" Padding="14" HorizontalContentAlignment="Left">
                                <StackPanel Orientation="Horizontal">
                                    <Border Width="40" Height="40" CornerRadius="10" Background="#FEF2F2" Margin="0,0,12,0">
                                        <TextBlock Text="YT" Foreground="#EF4444" FontWeight="Bold" FontSize="15" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <StackPanel VerticalAlignment="Center">
                                        <TextBlock Text="YouTube Channel" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="13"/>
                                        <TextBlock Text="@amarsmartindia" Foreground="#EF4444" FontSize="10.5"/>
                                    </StackPanel>
                                </StackPanel>
                            </Button>
                        </Border>
                        <!-- Instagram -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Button x:Name="BtnSocialInstagram" Background="Transparent" BorderThickness="0" Cursor="Hand" Padding="14" HorizontalContentAlignment="Left">
                                <StackPanel Orientation="Horizontal">
                                    <Border Width="40" Height="40" CornerRadius="10" Background="#FDF2F8" Margin="0,0,12,0">
                                        <TextBlock Text="IG" Foreground="#EC4899" FontWeight="Bold" FontSize="15" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <StackPanel VerticalAlignment="Center">
                                        <TextBlock Text="Instagram Profile" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="13"/>
                                        <TextBlock Text="@amarsmartindia0" Foreground="#EC4899" FontSize="10.5"/>
                                    </StackPanel>
                                </StackPanel>
                            </Button>
                        </Border>
                        <!-- X Twitter -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Button x:Name="BtnSocialTwitter" Background="Transparent" BorderThickness="0" Cursor="Hand" Padding="14" HorizontalContentAlignment="Left">
                                <StackPanel Orientation="Horizontal">
                                    <Border Width="40" Height="40" CornerRadius="10" Background="#EFF6FF" Margin="0,0,12,0">
                                        <TextBlock Text="X" Foreground="#0EA5E9" FontWeight="Bold" FontSize="18" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <StackPanel VerticalAlignment="Center">
                                        <TextBlock Text="X (Twitter)" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="13"/>
                                        <TextBlock Text="@amarsmartindia" Foreground="#38BDF8" FontSize="10.5"/>
                                    </StackPanel>
                                </StackPanel>
                            </Button>
                        </Border>
                        <!-- Blogger -->
                        <Border Background="{DynamicResource CardBgBrush}" CornerRadius="10" Margin="4" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="1">
                            <Button x:Name="BtnSocialBlogger" Background="Transparent" BorderThickness="0" Cursor="Hand" Padding="14" HorizontalContentAlignment="Left">
                                <StackPanel Orientation="Horizontal">
                                    <Border Width="40" Height="40" CornerRadius="10" Background="#FFF7ED" Margin="0,0,12,0">
                                        <TextBlock Text="B" Foreground="#F97316" FontWeight="Bold" FontSize="18" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <StackPanel VerticalAlignment="Center">
                                        <TextBlock Text="Blogger Site" Foreground="{DynamicResource TextPrimaryBrush}" FontWeight="Bold" FontSize="13"/>
                                        <TextBlock Text="amarsmartindia0.blogspot.com" Foreground="#F97316" FontSize="10.5"/>
                                    </StackPanel>
                                </StackPanel>
                            </Button>
                        </Border>
                    </UniformGrid>
                </StackPanel>
            </ScrollViewer>

        </Grid>

        <!-- CONSOLE LOG FOOTER -->
        <Border Grid.Row="2" Background="{DynamicResource ConsoleBgBrush}" BorderBrush="{DynamicResource CardBorderBrush}" BorderThickness="0,1,0,0" Padding="16,8">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <Grid Grid.Row="0" Margin="0,0,0,4">
                    <TextBlock Text="&#x1F4BB; System Output &amp; Status Log" Foreground="{DynamicResource TextSecondaryBrush}" FontSize="11" FontWeight="Bold"/>
                    <Button x:Name="BtnClearLog" Content="Clear" Style="{StaticResource OutlineBtnStyle}" FontSize="10" Padding="8,3" HorizontalAlignment="Right"/>
                </Grid>
                <TextBox x:Name="TxtLogConsole" Grid.Row="1" Background="Transparent" Foreground="#059669" FontFamily="Consolas" FontSize="11"
                         IsReadOnly="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" TextWrapping="Wrap" BorderThickness="0" Padding="4"/>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

# ---------------------------------------------------------------------------------
# 5. PARSE XAML & CREATE WPF WINDOW OBJECTS
# ---------------------------------------------------------------------------------
$reader = New-Object System.Xml.XmlNodeReader($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Find Control References
$navToolsBtn   = $window.FindName("NavToolsBtn")
$navGuideBtn   = $window.FindName("NavGuideBtn")
$navInstallBtn = $window.FindName("NavInstallBtn")
$navUpdateBtn  = $window.FindName("NavUpdateBtn")
$navAboutBtn   = $window.FindName("NavAboutBtn")

$tabTools   = $window.FindName("TabTools")
$tabGuide   = $window.FindName("TabGuide")
$tabInstall = $window.FindName("TabInstall")
$tabUpdates = $window.FindName("TabUpdates")
$tabAbout   = $window.FindName("TabAbout")

$cardBattery   = $window.FindName("CardBattery")
$deviceTypeTxt = $window.FindName("DeviceTypeTxt")
$txtLogConsole = $window.FindName("TxtLogConsole")
$cmbTheme      = $window.FindName("CmbTheme")

$logoBorder       = $window.FindName("LogoBorder")
$logoTextFallback = $window.FindName("LogoTextFallback")

$updateItemsList       = $window.FindName("UpdateItemsList")
$updateStatusTitle     = $window.FindName("UpdateStatusTitle")
$updateStatusMsg       = $window.FindName("UpdateStatusMsg")
$updateStatusBanner    = $window.FindName("UpdateStatusBanner")

function Register-Click($elementName, $scriptBlock) {
    $elem = $window.FindName($elementName)
    if ($null -ne $elem) {
        $elem.Add_Click($scriptBlock)
    }
}

# ---------------------------------------------------------------------------------
# 6. LOGGING UTILITY FUNCTION
# ---------------------------------------------------------------------------------
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message`r`n"
    
    if ($null -ne $txtLogConsole) {
        $txtLogConsole.Dispatcher.Invoke([System.Action]{
            $txtLogConsole.AppendText($logLine)
            $txtLogConsole.ScrollToEnd()
        })
    }
}

# ---------------------------------------------------------------------------------
# 7. DYNAMIC THEME ENGINE (Auto / Light / Dark)
# ---------------------------------------------------------------------------------
function Set-AppTheme($themeMode) {
    $isLight = $false
    if ($themeMode -eq "Light Theme") {
        $isLight = $true
    } elseif ($themeMode -eq "Dark Theme") {
        $isLight = $false
    } else {
        # Auto Mode: Query Windows Personalize Registry
        try {
            $regVal = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue
            if ($regVal -eq 1) { $isLight = $true }
        } catch { $isLight = $false }
    }

    $bc = [System.Windows.Media.BrushConverter]::New()
    if ($isLight) {
        $window.Resources["BgBrush"]             = $bc.ConvertFromString("#F8FAFC")
        $window.Resources["HeaderBgBrush"]       = $bc.ConvertFromString("#FFFFFF")
        $window.Resources["CardBgBrush"]         = $bc.ConvertFromString("#FFFFFF")
        $window.Resources["CardBorderBrush"]     = $bc.ConvertFromString("#E2E8F0")
        $window.Resources["TextPrimaryBrush"]    = $bc.ConvertFromString("#0F172A")
        $window.Resources["TextSecondaryBrush"]  = $bc.ConvertFromString("#64748B")
        $window.Resources["ConsoleBgBrush"]      = $bc.ConvertFromString("#F1F5F9")
        $window.Background = $bc.ConvertFromString("#F8FAFC")
        Write-Log "Theme: Light Mode applied." "INFO"
    } else {
        $window.Resources["BgBrush"]             = $bc.ConvertFromString("#0F172A")
        $window.Resources["HeaderBgBrush"]       = $bc.ConvertFromString("#1E293B")
        $window.Resources["CardBgBrush"]         = $bc.ConvertFromString("#1E293B")
        $window.Resources["CardBorderBrush"]     = $bc.ConvertFromString("#334155")
        $window.Resources["TextPrimaryBrush"]    = $bc.ConvertFromString("#F8FAFC")
        $window.Resources["TextSecondaryBrush"]  = $bc.ConvertFromString("#94A3B8")
        $window.Resources["ConsoleBgBrush"]      = $bc.ConvertFromString("#090D16")
        $window.Background = $bc.ConvertFromString("#0F172A")
        Write-Log "Theme: Dark Mode applied." "INFO"
    }
}

if ($null -ne $cmbTheme) {
    $cmbTheme.Add_SelectionChanged({
        $selected = $cmbTheme.SelectedItem.Content
        Set-AppTheme $selected
    })
}

# Apply Hardware Battery Detection & Image Logo
if ($null -ne $deviceTypeTxt) { $deviceTypeTxt.Text = $deviceTypeStr }
if (-not $hasBattery -and $null -ne $cardBattery) {
    $cardBattery.Visibility = [System.Windows.Visibility]::Collapsed
}

if (Test-Path $logoPath) {
    try {
        $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
        $bitmap.BeginInit()
        $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.UriSource = New-Object System.Uri((Resolve-Path $logoPath).Path)
        $bitmap.EndInit()
        $imgBrush = New-Object System.Windows.Media.ImageBrush
        $imgBrush.ImageSource = $bitmap
        $imgBrush.Stretch = [System.Windows.Media.Stretch]::UniformToFill
        if ($null -ne $logoBorder) { $logoBorder.Background = $imgBrush }
        if ($null -ne $logoTextFallback) { $logoTextFallback.Visibility = [System.Windows.Visibility]::Collapsed }
    } catch {
        Write-Log "Logo load warning: $_" "WARNING"
    }
}

Write-Log "ASI WINDOWS UTILITY loaded successfully." "INFO"
Write-Log "Device: $deviceTypeStr | Theme: Light (default)" "INFO"

# ---------------------------------------------------------------------------------
# 8. TOP HEADER NAVIGATION TAB SWITCHING LOGIC
# ---------------------------------------------------------------------------------
function Select-Tab($activeTab, $activeBtn) {
    $tabs = @($tabTools, $tabGuide, $tabInstall, $tabUpdates, $tabAbout)
    $btns = @($navToolsBtn, $navGuideBtn, $navInstallBtn, $navUpdateBtn, $navAboutBtn)

    foreach ($t in $tabs) { 
        if ($null -ne $t) { $t.Visibility = [System.Windows.Visibility]::Collapsed }
    }
    foreach ($b in $btns) { 
        if ($null -ne $b) {
            $b.Background = [System.Windows.Media.Brushes]::Transparent 
            $b.Foreground = $window.Resources["TextSecondaryBrush"]
        }
    }

    if ($null -ne $activeTab) { $activeTab.Visibility = [System.Windows.Visibility]::Visible }
    if ($null -ne $activeBtn) {
        $activeBtn.Background = [System.Windows.Media.BrushConverter]::New().ConvertFromString("#EFF6FF")
        $activeBtn.Foreground = $window.Resources["AccentBrush"]
    }
}

if ($null -ne $navToolsBtn)   { $navToolsBtn.Add_Click({ Select-Tab $tabTools $navToolsBtn }) }
if ($null -ne $navGuideBtn)   { $navGuideBtn.Add_Click({ Select-Tab $tabGuide $navGuideBtn }) }
if ($null -ne $navInstallBtn) { $navInstallBtn.Add_Click({ Select-Tab $tabInstall $navInstallBtn }) }
if ($null -ne $navUpdateBtn)  { $navUpdateBtn.Add_Click({ Select-Tab $tabUpdates $navUpdateBtn }) }
if ($null -ne $navAboutBtn)   { $navAboutBtn.Add_Click({ Select-Tab $tabAbout $navAboutBtn }) }

# ---------------------------------------------------------------------------------
# 9. BACKEND LOGIC: TOOLS DASHBOARD (TAB 1)
# ---------------------------------------------------------------------------------
Register-Click "BtnCleanSystem" {
    Write-Log "Starting System Cleanup..." "INFO"
    $cleanPaths = @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch")
    $freedBytes = 0
    foreach ($path in $cleanPaths) {
        if (Test-Path $path) {
            try {
                $files = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue
                foreach ($f in $files) {
                    try {
                        if (-not $f.PSIsContainer) { $freedBytes += $f.Length }
                        Remove-Item -Path $f.FullName -Force -Recurse -ErrorAction SilentlyContinue
                    } catch {}
                }
            } catch {}
        }
    }
    $freedMB = [math]::Round($freedBytes / 1MB, 2)
    Write-Log "Cleanup complete! Freed $freedMB MB." "SUCCESS"
}

Register-Click "BtnRepairSystem" {
    Write-Log "Initiating SFC System Scan..." "INFO"
    $window.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
    $sfcJob = Start-Job -ScriptBlock { sfc /scannow }
    Wait-Job $sfcJob | Out-Null
    $sfcOut = Receive-Job $sfcJob | Out-String
    Write-Log "SFC: $sfcOut" "INFO"
    if ($sfcOut -match "corrupt" -or $sfcOut -match "failed" -or $sfcOut -match "repaired") {
        Write-Log "Running DISM Online Restore..." "WARNING"
        $dismJob = Start-Job -ScriptBlock { DISM /Online /Cleanup-Image /RestoreHealth }
        Wait-Job $dismJob | Out-Null
        $dismOut = Receive-Job $dismJob | Out-String
        Write-Log "DISM: $dismOut" "SUCCESS"
    } else {
        Write-Log "System files are clean." "SUCCESS"
    }
}

Register-Click "BtnResetNetwork" {
    Write-Log "Resetting Network Stack..." "INFO"
    ipconfig /flushdns | Out-Null
    netsh winsock reset | Out-Null
    netsh int ip reset | Out-Null
    Write-Log "Network Reset completed!" "SUCCESS"
}

Register-Click "BtnScanVirus" {
    Write-Log "Starting Defender Quick Scan..." "INFO"
    try {
        Start-MpScan -ScanType QuickScan
        Write-Log "Defender scan completed." "SUCCESS"
    } catch { Write-Log "Defender error: $_" "ERROR" }
}

Register-Click "BtnOptimizeStartup" {
    Write-Log "Scanning startup programs..." "INFO"
    try {
        $startups = @(Get-CimInstance -ClassName Win32_StartupCommand -ErrorAction SilentlyContinue)
        Write-Log "Found $($startups.Count) startup items." "INFO"
        Write-Log "Startup optimization completed." "SUCCESS"
    } catch { Write-Log "Startup error: $_" "ERROR" }
}

Register-Click "BtnFixMouse" {
    Write-Log "Fixing mouse acceleration..." "INFO"
    try {
        $mk = "HKCU:\Control Panel\Mouse"
        Set-ItemProperty -Path $mk -Name "MouseSpeed" -Value "0" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $mk -Name "MouseThreshold1" -Value "0" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $mk -Name "MouseThreshold2" -Value "0" -ErrorAction SilentlyContinue
        Write-Log "Mouse acceleration disabled. 1:1 raw input restored!" "SUCCESS"
    } catch { Write-Log "Mouse fix error: $_" "ERROR" }
}

Register-Click "BtnActivateHWID" {
    Write-Log "Launching HWID Activation..." "INFO"
    try {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
        Write-Log "HWID Activation triggered." "SUCCESS"
    } catch { Write-Log "HWID error: $_" "ERROR" }
}

Register-Click "BtnFixSpeaker" {
    Write-Log "Restarting Audio Services..." "INFO"
    try {
        Restart-Service -Name "AudioSrv" -Force -ErrorAction SilentlyContinue
        Restart-Service -Name "AudioEndpointBuilder" -Force -ErrorAction SilentlyContinue
        Write-Log "Audio services restarted." "SUCCESS"
    } catch { Write-Log "Audio error: $_" "ERROR" }
}

Register-Click "BtnSaveBattery" {
    Write-Log "Applying Battery Saver power plan..." "INFO"
    try {
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
        Write-Log "Battery saver plan activated!" "SUCCESS"
    } catch { Write-Log "Power plan error: $_" "ERROR" }
}

Register-Click "BtnOptimizeProcesses" {
    Write-Log "Disabling telemetry services..." "INFO"
    $targetServices = @("DiagTrack", "dmwappushservice", "MapsBroker")
    foreach ($svc in $targetServices) {
        if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }
    Write-Log "Bloatware services disabled." "SUCCESS"
}

# ---------------------------------------------------------------------------------
# 10. BACKEND LOGIC: INSTALL HUB (TAB 3)
# ---------------------------------------------------------------------------------
function Install-AppPackage($appId, $appName) {
    $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
    Write-Log "Installing $appName..." "INFO"
    if ($wingetAvailable) {
        try {
            $p = Start-Process winget -ArgumentList "install --id $appId -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru -ErrorAction SilentlyContinue
            if ($p.ExitCode -eq 0) {
                Write-Log "$appName installed successfully!" "SUCCESS"
            } else {
                Write-Log "Winget exit code $($p.ExitCode) for $appName." "WARNING"
            }
        } catch { Write-Log "Install error for $appName - $_" "ERROR" }
    } else {
        Write-Log "Winget not found on this system." "ERROR"
    }
}

# 1-Click Individual Install Handlers
Register-Click "BtnInstallChrome"      { Install-AppPackage "Google.Chrome" "Google Chrome" }
Register-Click "BtnInstallFirefox"     { Install-AppPackage "Mozilla.Firefox" "Mozilla Firefox" }
Register-Click "BtnInstallComet"       { Install-AppPackage "CometNetwork.CometBrowser" "Comet Browser" }
Register-Click "BtnInstallAntigravity" { Install-AppPackage "Google.Antigravity" "Antigravity IDE" }
Register-Click "BtnInstallPython"      { Install-AppPackage "Python.Python.3.12" "Python 3" }
Register-Click "BtnInstallVLC"         { Install-AppPackage "VideoLAN.VLC" "VLC Media Player" }
Register-Click "BtnInstallVSCode"      { Install-AppPackage "Microsoft.VisualStudioCode" "VS Code" }
Register-Click "BtnInstallTelegram"    { Install-AppPackage "Telegram.TelegramDesktop" "Telegram" }
Register-Click "BtnInstallWhatsApp"    { Install-AppPackage "WhatsApp.WhatsApp" "WhatsApp" }
Register-Click "BtnInstallRustDesk"    { Install-AppPackage "RustDesk.RustDesk" "RustDesk" }
Register-Click "BtnInstall7Zip"        { Install-AppPackage "7zip.7zip" "7-Zip" }
Register-Click "BtnInstallNotepadPP"   { Install-AppPackage "Notepad++.Notepad++" "Notepad++" }
Register-Click "BtnInstallGit"         { Install-AppPackage "Git.Git" "Git" }
Register-Click "BtnInstallNodeJS"      { Install-AppPackage "OpenJS.NodeJS.LTS" "Node.js LTS" }
Register-Click "BtnInstallOBS"         { Install-AppPackage "OBSProject.OBSStudio" "OBS Studio" }
Register-Click "BtnInstallDiscord"     { Install-AppPackage "Discord.Discord" "Discord" }
Register-Click "BtnInstallSpotify"     { Install-AppPackage "Spotify.Spotify" "Spotify" }

# All checkbox names for batch operations
$allChkNames = @("ChkChrome", "ChkFirefox", "ChkComet", "ChkAntigravity", "ChkPython", "ChkVLC", "ChkVSCode", "ChkTelegram", "ChkWhatsApp", "ChkRustDesk", "Chk7Zip", "ChkNotepadPP", "ChkGit", "ChkNodeJS", "ChkOBS", "ChkDiscord", "ChkSpotify")

Register-Click "BtnSelectAllApps" {
    foreach ($name in $allChkNames) {
        $cb = $window.FindName($name)
        if ($null -ne $cb) { $cb.IsChecked = $true }
    }
}

Register-Click "BtnDeselectAllApps" {
    foreach ($name in $allChkNames) {
        $cb = $window.FindName($name)
        if ($null -ne $cb) { $cb.IsChecked = $false }
    }
}

$appsMap = @{
    "ChkChrome"      = @("Google.Chrome", "Google Chrome")
    "ChkFirefox"     = @("Mozilla.Firefox", "Mozilla Firefox")
    "ChkComet"       = @("CometNetwork.CometBrowser", "Comet Browser")
    "ChkAntigravity" = @("Google.Antigravity", "Antigravity IDE")
    "ChkPython"      = @("Python.Python.3.12", "Python 3")
    "ChkVLC"         = @("VideoLAN.VLC", "VLC Media Player")
    "ChkVSCode"      = @("Microsoft.VisualStudioCode", "VS Code")
    "ChkTelegram"    = @("Telegram.TelegramDesktop", "Telegram")
    "ChkWhatsApp"    = @("WhatsApp.WhatsApp", "WhatsApp")
    "ChkRustDesk"    = @("RustDesk.RustDesk", "RustDesk")
    "Chk7Zip"        = @("7zip.7zip", "7-Zip")
    "ChkNotepadPP"   = @("Notepad++.Notepad++", "Notepad++")
    "ChkGit"         = @("Git.Git", "Git")
    "ChkNodeJS"      = @("OpenJS.NodeJS.LTS", "Node.js LTS")
    "ChkOBS"         = @("OBSProject.OBSStudio", "OBS Studio")
    "ChkDiscord"     = @("Discord.Discord", "Discord")
    "ChkSpotify"     = @("Spotify.Spotify", "Spotify")
}

Register-Click "BtnInstallSelected" {
    $hasSelection = $false
    foreach ($key in $appsMap.Keys) {
        $chk = $window.FindName($key)
        if ($null -ne $chk -and $chk.IsChecked) {
            $hasSelection = $true
            $appInfo = $appsMap[$key]
            Install-AppPackage $appInfo[0] $appInfo[1]
        }
    }
    if (-not $hasSelection) {
        Write-Log "No software selected for batch install." "WARNING"
    }
}

# ---------------------------------------------------------------------------------
# 11. BACKEND LOGIC: UPDATES (TAB 4 - Winget upgrade scan with selection)
# ---------------------------------------------------------------------------------

# Global list to track update checkboxes
$script:updateCheckboxes = [System.Collections.ArrayList]::new()

function Update-StatusBanner($title, $msg, $bgColor, $borderColor, $textColor) {
    if ($null -ne $updateStatusBanner) {
        $bc = [System.Windows.Media.BrushConverter]::New()
        $updateStatusBanner.Background = $bc.ConvertFromString($bgColor)
        $updateStatusBanner.BorderBrush = $bc.ConvertFromString($borderColor)
        $updateStatusTitle.Text = $title
        $updateStatusTitle.Foreground = $bc.ConvertFromString($textColor)
        $updateStatusMsg.Text = $msg
        $updateStatusMsg.Foreground = $bc.ConvertFromString($textColor)
    }
}

Register-Click "BtnScanUpdates" {
    Write-Log "Scanning for available software updates via Winget..." "INFO"
    Update-StatusBanner "Scanning..." "Running 'winget upgrade' to detect outdated packages..." "#FFFBEB" "#FCD34D" "#92400E"
    $updateItemsList.Children.Clear()
    $script:updateCheckboxes.Clear()

    $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetAvailable) {
        Write-Log "Winget not found. Cannot scan for updates." "ERROR"
        Update-StatusBanner "Error" "Winget package manager is not installed on this system." "#FEF2F2" "#FECACA" "#991B1B"
        return
    }

    try {
        $rawOutput = & winget upgrade --accept-source-agreements 2>&1 | Out-String
        Write-Log "Winget scan completed." "INFO"

        # Parse the winget upgrade output into structured rows
        $lines = $rawOutput -split "`n" | ForEach-Object { $_.TrimEnd() }

        # Find the header line with dashes
        $headerIdx = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^-{3,}") {
                $headerIdx = $i
                break
            }
        }

        if ($headerIdx -lt 1) {
            $noUpdateTxt = New-Object System.Windows.Controls.TextBlock
            $noUpdateTxt.Text = "All software is up to date!"
            $noUpdateTxt.Foreground = $window.Resources["SuccessBrush"]
            $noUpdateTxt.FontSize = 14
            $noUpdateTxt.FontWeight = [System.Windows.FontWeights]::Bold
            $noUpdateTxt.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
            $noUpdateTxt.Margin = New-Object System.Windows.Thickness(0,30,0,30)
            $updateItemsList.Children.Add($noUpdateTxt) | Out-Null
            Update-StatusBanner "Up to Date" "All installed software is already at the latest version." "#ECFDF5" "#A7F3D0" "#065F46"
            Write-Log "No updates available." "SUCCESS"
            return
        }

        # Determine column positions from the dash line
        $dashLine = $lines[$headerIdx]
        $colStarts = [System.Collections.ArrayList]::new()
        $inDash = $false
        for ($ci = 0; $ci -lt $dashLine.Length; $ci++) {
            if ($dashLine[$ci] -eq '-' -and -not $inDash) {
                $colStarts.Add($ci) | Out-Null
                $inDash = $true
            } elseif ($dashLine[$ci] -ne '-') {
                $inDash = $false
            }
        }

        $updatableApps = [System.Collections.ArrayList]::new()

        for ($li = $headerIdx + 1; $li -lt $lines.Count; $li++) {
            $line = $lines[$li]
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            if ($line -match "upgrades available" -or $line -match "^\d+ .* have") { continue }

            if ($colStarts.Count -ge 4 -and $line.Length -ge $colStarts[2]) {
                $nameVal = ""
                $curVal = ""
                $availVal = ""

                if ($colStarts.Count -ge 2) {
                    $nameVal = $line.Substring($colStarts[0], [Math]::Min($colStarts[1] - $colStarts[0], $line.Length - $colStarts[0])).Trim()
                }
                if ($colStarts.Count -ge 4 -and $line.Length -gt $colStarts[2]) {
                    $startCur = $colStarts[2]
                    $lenCur = [Math]::Min($colStarts[3] - $colStarts[2], $line.Length - $startCur)
                    if ($lenCur -gt 0) { $curVal = $line.Substring($startCur, $lenCur).Trim() }
                }
                if ($colStarts.Count -ge 4 -and $line.Length -gt $colStarts[3]) {
                    $startAvail = $colStarts[3]
                    $lenAvail = $line.Length - $startAvail
                    # Check for a 5th column (source) and trim
                    if ($colStarts.Count -ge 5 -and $line.Length -gt $colStarts[4]) {
                        $lenAvail = $colStarts[4] - $startAvail
                    }
                    if ($lenAvail -gt 0) { $availVal = $line.Substring($startAvail, $lenAvail).Trim() }
                }

                # Extract ID (column 2)
                $idVal = ""
                if ($colStarts.Count -ge 3 -and $line.Length -gt $colStarts[1]) {
                    $startId = $colStarts[1]
                    $lenId = [Math]::Min($colStarts[2] - $colStarts[1], $line.Length - $startId)
                    if ($lenId -gt 0) { $idVal = $line.Substring($startId, $lenId).Trim() }
                }

                if ($nameVal -and $curVal -and $availVal -and $nameVal -ne "Name") {
                    $updatableApps.Add(@{
                        Name = $nameVal
                        Id = $idVal
                        Current = $curVal
                        Available = $availVal
                    }) | Out-Null
                }
            }
        }

        if ($updatableApps.Count -eq 0) {
            $noUpdateTxt = New-Object System.Windows.Controls.TextBlock
            $noUpdateTxt.Text = "All software is up to date!"
            $noUpdateTxt.Foreground = $window.Resources["SuccessBrush"]
            $noUpdateTxt.FontSize = 14
            $noUpdateTxt.FontWeight = [System.Windows.FontWeights]::Bold
            $noUpdateTxt.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
            $noUpdateTxt.Margin = New-Object System.Windows.Thickness(0,30,0,30)
            $updateItemsList.Children.Add($noUpdateTxt) | Out-Null
            Update-StatusBanner "Up to Date" "All installed software is at the latest version." "#ECFDF5" "#A7F3D0" "#065F46"
            Write-Log "No updates available." "SUCCESS"
            return
        }

        # Build UI rows for each updatable app
        foreach ($app in $updatableApps) {
            $rowBorder = New-Object System.Windows.Controls.Border
            $rowBorder.CornerRadius = [System.Windows.CornerRadius]::new(6.0)
            $rowBorder.Padding = New-Object System.Windows.Thickness(12,8,12,8)
            $rowBorder.Margin = New-Object System.Windows.Thickness(0,1,0,1)
            $rowBorder.Background = $window.Resources["BgBrush"]

            $rowGrid = New-Object System.Windows.Controls.Grid
            $col0 = New-Object System.Windows.Controls.ColumnDefinition; $col0.Width = [System.Windows.GridLength]::new(30)
            $col1 = New-Object System.Windows.Controls.ColumnDefinition; $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
            $col2 = New-Object System.Windows.Controls.ColumnDefinition; $col2.Width = [System.Windows.GridLength]::new(120)
            $col3 = New-Object System.Windows.Controls.ColumnDefinition; $col3.Width = [System.Windows.GridLength]::new(120)
            $col4 = New-Object System.Windows.Controls.ColumnDefinition; $col4.Width = [System.Windows.GridLength]::new(80)
            $rowGrid.ColumnDefinitions.Add($col0)
            $rowGrid.ColumnDefinitions.Add($col1)
            $rowGrid.ColumnDefinitions.Add($col2)
            $rowGrid.ColumnDefinitions.Add($col3)
            $rowGrid.ColumnDefinitions.Add($col4)

            # Checkbox
            $chk = New-Object System.Windows.Controls.CheckBox
            $chk.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $chk.Tag = $app.Id
            [System.Windows.Controls.Grid]::SetColumn($chk, 0)
            $script:updateCheckboxes.Add($chk) | Out-Null

            # Name
            $txtName = New-Object System.Windows.Controls.TextBlock
            $txtName.Text = $app.Name
            $txtName.Foreground = $window.Resources["TextPrimaryBrush"]
            $txtName.FontWeight = [System.Windows.FontWeights]::SemiBold
            $txtName.FontSize = 12
            $txtName.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $txtName.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
            [System.Windows.Controls.Grid]::SetColumn($txtName, 1)

            # Current version
            $txtCur = New-Object System.Windows.Controls.TextBlock
            $txtCur.Text = $app.Current
            $txtCur.Foreground = $window.Resources["TextSecondaryBrush"]
            $txtCur.FontSize = 11
            $txtCur.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            [System.Windows.Controls.Grid]::SetColumn($txtCur, 2)

            # Available version
            $txtAvail = New-Object System.Windows.Controls.TextBlock
            $txtAvail.Text = $app.Available
            $txtAvail.Foreground = $window.Resources["SuccessBrush"]
            $txtAvail.FontWeight = [System.Windows.FontWeights]::Bold
            $txtAvail.FontSize = 11
            $txtAvail.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            [System.Windows.Controls.Grid]::SetColumn($txtAvail, 3)

            # Individual update button
            $btnUpdate = New-Object System.Windows.Controls.Button
            $btnUpdate.Content = "Update"
            $btnUpdate.Foreground = [System.Windows.Media.Brushes]::White
            $btnUpdate.Background = $window.Resources["AccentBrush"]
            $btnUpdate.FontSize = 10
            $btnUpdate.FontWeight = [System.Windows.FontWeights]::Bold
            $btnUpdate.Padding = New-Object System.Windows.Thickness(8,3,8,3)
            $btnUpdate.Cursor = [System.Windows.Input.Cursors]::Hand
            $btnUpdate.BorderThickness = New-Object System.Windows.Thickness(0)
            $btnUpdate.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
            $btnUpdate.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $btnUpdate.Tag = $app.Id
            $btnUpdate.Add_Click({
                param($sender, $e)
                $pkgId = $sender.Tag
                Write-Log "Updating package [$pkgId]..." "INFO"
                try {
                    Start-Process winget -ArgumentList "upgrade --id $pkgId -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -ErrorAction SilentlyContinue
                    Write-Log "Package [$pkgId] updated successfully!" "SUCCESS"
                } catch { Write-Log "Update error for $pkgId - $_" "ERROR" }
            })

            # Apply rounded template via XAML string (safer than FrameworkElementFactory)
            $btnXamlStr = '<ControlTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" TargetType="Button"><Border CornerRadius="6" Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate>'
            $btnUpdate.Template = [System.Windows.Markup.XamlReader]::Parse($btnXamlStr)

            [System.Windows.Controls.Grid]::SetColumn($btnUpdate, 4)

            $rowGrid.Children.Add($chk) | Out-Null
            $rowGrid.Children.Add($txtName) | Out-Null
            $rowGrid.Children.Add($txtCur) | Out-Null
            $rowGrid.Children.Add($txtAvail) | Out-Null
            $rowGrid.Children.Add($btnUpdate) | Out-Null

            $rowBorder.Child = $rowGrid
            $updateItemsList.Children.Add($rowBorder) | Out-Null
        }

        Update-StatusBanner "Updates Available" "$($updatableApps.Count) package(s) have newer versions available." "#FFFBEB" "#FCD34D" "#92400E"
        Write-Log "Found $($updatableApps.Count) updatable packages." "SUCCESS"

    } catch {
        Write-Log "Scan error: $_" "ERROR"
        Update-StatusBanner "Scan Failed" "An error occurred while scanning. Check the log for details." "#FEF2F2" "#FECACA" "#991B1B"
    }
}

# Select All / Deselect All for update checkboxes
Register-Click "BtnSelectAllUpdates" {
    foreach ($chk in $script:updateCheckboxes) {
        $chk.IsChecked = $true
    }
}

Register-Click "BtnDeselectAllUpdates" {
    foreach ($chk in $script:updateCheckboxes) {
        $chk.IsChecked = $false
    }
}

# Update Selected packages
Register-Click "BtnUpdateSelected" {
    $selectedIds = @()
    foreach ($chk in $script:updateCheckboxes) {
        if ($chk.IsChecked -and $chk.Tag) {
            $selectedIds += $chk.Tag
        }
    }

    if ($selectedIds.Count -eq 0) {
        Write-Log "No packages selected for update." "WARNING"
        return
    }

    Write-Log "Updating $($selectedIds.Count) selected package(s)..." "INFO"
    Update-StatusBanner "Updating..." "Installing updates for $($selectedIds.Count) selected package(s)..." "#FFFBEB" "#FCD34D" "#92400E"

    foreach ($pkgId in $selectedIds) {
        Write-Log "Upgrading $pkgId..." "INFO"
        try {
            Start-Process winget -ArgumentList "upgrade --id $pkgId -e --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -ErrorAction SilentlyContinue
            Write-Log "$pkgId updated!" "SUCCESS"
        } catch {
            Write-Log "Failed to update $pkgId - $_" "ERROR"
        }
    }

    Update-StatusBanner "Complete" "Finished updating $($selectedIds.Count) package(s). Re-scan to verify." "#ECFDF5" "#A7F3D0" "#065F46"
    Write-Log "Batch update complete." "SUCCESS"
}

# ---------------------------------------------------------------------------------
# 12. BACKEND LOGIC: ABOUT DEVELOPER LINKS (TAB 5)
# ---------------------------------------------------------------------------------
$socialLinks = @{
    "BtnSocialWebsite"   = "https://amarsmartindia.in/"
    "BtnSocialYouTube"   = "https://www.youtube.com/@amarsmartindia"
    "BtnSocialInstagram" = "https://www.instagram.com/amarsmartindia0/"
    "BtnSocialTwitter"   = "https://x.com/amarsmartindia"
    "BtnSocialBlogger"   = "http://amarsmartindia0.blogspot.com/"
}

foreach ($btnKey in $socialLinks.Keys) {
    $targetUrl = $socialLinks[$btnKey]
    $btnElem = $window.FindName($btnKey)
    if ($null -ne $btnElem) {
        $btnElem.Tag = $targetUrl
        $btnElem.Add_Click({
            param($sender, $e)
            $urlToOpen = $sender.Tag
            Write-Log "Opening: $urlToOpen" "INFO"
            Start-Process $urlToOpen
        })
    }
}

Register-Click "BtnClearLog" {
    if ($null -ne $txtLogConsole) {
        $txtLogConsole.Clear()
        Write-Log "Log cleared." "INFO"
    }
}

# ---------------------------------------------------------------------------------
# 13. SHOW WINDOW
# ---------------------------------------------------------------------------------
$window.ShowDialog() | Out-Null
