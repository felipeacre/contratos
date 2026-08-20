</div><!-- /container-fluid -->

<footer class="footer mt-auto py-2 text-center">
    <small class="text-muted">
        <?= APP_NAME ?> v<?= APP_VERSION ?> &mdash;
        <?= date('d/m/Y H:i') ?>
    </small>
</footer>

<!-- Scripts -->
<script src="<?= BASE_URL ?>/assets/js/bootstrap.bundle.min.js"></script>
<script src="<?= BASE_URL ?>/assets/js/jquery-3.7.1.min.js"></script>
<script src="<?= BASE_URL ?>/assets/js/jquery.dataTables.min.js"></script>
<script src="<?= BASE_URL ?>/assets/js/dataTables.bootstrap5.min.js"></script>
<script src="<?= BASE_URL ?>/assets/js/app.js"></script>
<?php if (isset($extra_js)) echo $extra_js; ?>
</body>
</html>
