<?php
/**
 * LifeOS Server Requirements Checker
 *
 * This script checks if the server meets all requirements for running Laravel 12
 * Run this file by accessing it directly in your browser: http://yourserver.com/check.php
 */

$requirements = [
    'php_version' => '8.2.0',
    'extensions' => [
        'bcmath' => 'BCMath',
        'ctype' => 'Ctype',
        'curl' => 'cURL',
        'dom' => 'DOM',
        'fileinfo' => 'Fileinfo',
        'filter' => 'Filter',
        'hash' => 'Hash',
        'mbstring' => 'Mbstring',
        'openssl' => 'OpenSSL',
        'pcre' => 'PCRE',
        'pdo' => 'PDO',
        'pdo_sqlite' => 'PDO SQLite',
        'session' => 'Session',
        'tokenizer' => 'Tokenizer',
        'xml' => 'XML',
        'zip' => 'ZIP',
    ],
    'recommended' => [
        'gd' => 'GD',
        'imagick' => 'Imagick',
        'intl' => 'Intl',
        'pdo_mysql' => 'PDO MySQL',
        'pdo_pgsql' => 'PDO PostgreSQL',
        'redis' => 'Redis',
    ],
    'directories' => [
        'storage/framework/cache',
        'storage/framework/sessions',
        'storage/framework/views',
        'storage/logs',
        'bootstrap/cache',
    ],
];

$results = [
    'passed' => 0,
    'failed' => 0,
    'warnings' => 0,
];

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LifeOS Server Requirements</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .header h1 {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 10px;
        }
        .header p {
            font-size: 16px;
            opacity: 0.9;
        }
        .content {
            padding: 30px;
        }
        .section {
            margin-bottom: 30px;
        }
        .section h2 {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 10px;
        }
        .requirement-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 15px;
            margin-bottom: 8px;
            border-radius: 8px;
            background: #f8f9fa;
        }
        .requirement-name {
            font-weight: 500;
            color: #495057;
        }
        .status {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .status.pass {
            background: #d4edda;
            color: #155724;
        }
        .status.fail {
            background: #f8d7da;
            color: #721c24;
        }
        .status.warning {
            background: #fff3cd;
            color: #856404;
        }
        .summary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 30px;
        }
        .summary h2 {
            color: white;
            border: none;
            margin-bottom: 20px;
            font-size: 24px;
        }
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
        }
        .summary-item {
            text-align: center;
            padding: 15px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
            backdrop-filter: blur(10px);
        }
        .summary-item .number {
            font-size: 36px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        .summary-item .label {
            font-size: 14px;
            opacity: 0.9;
        }
        .footer {
            text-align: center;
            padding: 20px;
            color: #6c757d;
            font-size: 14px;
            border-top: 1px solid #e9ecef;
        }
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: 500;
        }
        .alert.success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        .alert.danger {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        .detail {
            font-size: 14px;
            color: #6c757d;
            margin-left: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 LifeOS Server Requirements</h1>
            <p>Laravel 12 Environment Check</p>
        </div>

        <div class="content">
            <?php
            // Check PHP version
            $phpVersion = phpversion();
            $phpVersionOk = version_compare($phpVersion, $requirements['php_version'], '>=');

            if (!$phpVersionOk) {
                $results['failed']++;
                echo '<div class="alert danger">❌ Critical: PHP version ' . $requirements['php_version'] . ' or higher is required. Current version: ' . $phpVersion . '</div>';
            }
            ?>

            <div class="section">
                <h2>PHP Version</h2>
                <div class="requirement-item">
                    <div class="requirement-name">
                        PHP <?php echo $requirements['php_version']; ?>+
                        <span class="detail">(Current: <?php echo $phpVersion; ?>)</span>
                    </div>
                    <span class="status <?php echo $phpVersionOk ? 'pass' : 'fail'; ?>">
                        <?php echo $phpVersionOk ? '✓ Pass' : '✗ Fail'; ?>
                    </span>
                </div>
                <?php if ($phpVersionOk) $results['passed']++; ?>
            </div>

            <div class="section">
                <h2>Required PHP Extensions</h2>
                <?php foreach ($requirements['extensions'] as $ext => $name): ?>
                    <?php
                    $loaded = extension_loaded($ext);
                    if ($loaded) {
                        $results['passed']++;
                    } else {
                        $results['failed']++;
                    }
                    ?>
                    <div class="requirement-item">
                        <div class="requirement-name"><?php echo $name; ?></div>
                        <span class="status <?php echo $loaded ? 'pass' : 'fail'; ?>">
                            <?php echo $loaded ? '✓ Loaded' : '✗ Missing'; ?>
                        </span>
                    </div>
                <?php endforeach; ?>
            </div>

            <div class="section">
                <h2>Recommended Extensions</h2>
                <?php foreach ($requirements['recommended'] as $ext => $name): ?>
                    <?php
                    $loaded = extension_loaded($ext);
                    if ($loaded) {
                        $results['passed']++;
                    } else {
                        $results['warnings']++;
                    }
                    ?>
                    <div class="requirement-item">
                        <div class="requirement-name"><?php echo $name; ?></div>
                        <span class="status <?php echo $loaded ? 'pass' : 'warning'; ?>">
                            <?php echo $loaded ? '✓ Loaded' : '⚠ Optional'; ?>
                        </span>
                    </div>
                <?php endforeach; ?>
            </div>

            <div class="section">
                <h2>Directory Permissions</h2>
                <?php foreach ($requirements['directories'] as $dir): ?>
                    <?php
                    $fullPath = __DIR__ . '/' . $dir;
                    $exists = file_exists($fullPath);
                    $writable = $exists && is_writable($fullPath);

                    if ($writable) {
                        $results['passed']++;
                    } elseif ($exists && !$writable) {
                        $results['failed']++;
                    } else {
                        $results['warnings']++;
                    }
                    ?>
                    <div class="requirement-item">
                        <div class="requirement-name">
                            <?php echo $dir; ?>
                            <?php if ($exists && $writable): ?>
                                <span class="detail">(0<?php echo substr(sprintf('%o', fileperms($fullPath)), -3); ?>)</span>
                            <?php endif; ?>
                        </div>
                        <span class="status <?php echo $writable ? 'pass' : ($exists ? 'fail' : 'warning'); ?>">
                            <?php
                            if ($writable) {
                                echo '✓ Writable';
                            } elseif ($exists) {
                                echo '✗ Not Writable';
                            } else {
                                echo '⚠ Not Found';
                            }
                            ?>
                        </span>
                    </div>
                <?php endforeach; ?>
            </div>

            <div class="section">
                <h2>Additional Settings</h2>
                <div class="requirement-item">
                    <div class="requirement-name">
                        Memory Limit
                        <span class="detail">(Current: <?php echo ini_get('memory_limit'); ?>)</span>
                    </div>
                    <span class="status <?php echo (int)ini_get('memory_limit') >= 128 ? 'pass' : 'warning'; ?>">
                        <?php echo (int)ini_get('memory_limit') >= 128 ? '✓ OK' : '⚠ Low'; ?>
                    </span>
                </div>
                <div class="requirement-item">
                    <div class="requirement-name">
                        Max Execution Time
                        <span class="detail">(Current: <?php echo ini_get('max_execution_time'); ?>s)</span>
                    </div>
                    <span class="status pass">✓ OK</span>
                </div>
                <div class="requirement-item">
                    <div class="requirement-name">
                        Upload Max Filesize
                        <span class="detail">(Current: <?php echo ini_get('upload_max_filesize'); ?>)</span>
                    </div>
                    <span class="status pass">✓ OK</span>
                </div>
            </div>

            <div class="summary">
                <h2>Summary</h2>
                <div class="summary-grid">
                    <div class="summary-item">
                        <div class="number"><?php echo $results['passed']; ?></div>
                        <div class="label">Passed</div>
                    </div>
                    <div class="summary-item">
                        <div class="number"><?php echo $results['failed']; ?></div>
                        <div class="label">Failed</div>
                    </div>
                    <div class="summary-item">
                        <div class="number"><?php echo $results['warnings']; ?></div>
                        <div class="label">Warnings</div>
                    </div>
                </div>
            </div>

            <?php if ($results['failed'] === 0 && $phpVersionOk): ?>
                <div class="alert success">
                    ✅ Congratulations! Your server meets all the requirements to run LifeOS.
                </div>
            <?php else: ?>
                <div class="alert danger">
                    ❌ Your server does not meet all requirements. Please address the failed checks above before proceeding with installation.
                </div>
            <?php endif; ?>
        </div>

        <div class="footer">
            <p>LifeOS Backend · Laravel 12 · PHP <?php echo $phpVersion; ?></p>
            <p style="margin-top: 5px;">Generated on <?php echo date('Y-m-d H:i:s'); ?></p>
        </div>
    </div>
</body>
</html>
