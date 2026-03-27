</div><!-- /container-fluid -->

<footer class="footer mt-auto py-2 text-center">
    <small class="text-muted">
        <?= APP_NAME ?> v<?= APP_VERSION ?> &mdash;
        <?= date('d/m/Y H:i') ?>
    </small>
</footer>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>
<script src="<?= BASE_URL ?>/assets/js/app.js"></script>
<?php if (isset($extra_js)) echo $extra_js; ?>
</body>
</html>
