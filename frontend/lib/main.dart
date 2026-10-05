import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/models.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken();
  final preferences = await SharedPreferences.getInstance();
  runApp(TravelEaseApp(darkMode: preferences.getBool('darkMode') ?? false));
}

class TravelEaseApp extends StatefulWidget {
  const TravelEaseApp({super.key, required this.darkMode});
  final bool darkMode;
  @override
  State<TravelEaseApp> createState() => _TravelEaseAppState();
}

class _TravelEaseAppState extends State<TravelEaseApp> {
  late bool darkMode = widget.darkMode;
  Future<void> _toggleTheme() async {
    setState(() => darkMode = !darkMode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('darkMode', darkMode);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TravelEase',
        theme: buildTheme(),
        darkTheme: buildTheme(dark: true),
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: ExplorePage(darkMode: darkMode, onToggleTheme: _toggleTheme),
      );
}

class ExplorePage extends StatefulWidget {
  const ExplorePage(
      {super.key, required this.darkMode, required this.onToggleTheme});
  final bool darkMode;
  final VoidCallback onToggleTheme;
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int tab = 0;
  String search = '';
  String category = 'All';
  AppUser? user;
  late Future<List<dynamic>> items = _load();
  final searchController = TextEditingController();

  Future<List<dynamic>> _load() async {
    final paths = ['/destinations', '/hotels', '/packages'];
    final query = <String, String>{'search': search, 'limit': '50'};
    if (tab == 0 && category != 'All') query['category'] = category;
    final response = await ApiService.get(paths[tab], query: query);
    final rows =
        (response as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
    return rows.map((row) {
      final json = Map<String, dynamic>.from(row as Map);
      if (tab == 0) return Destination.fromJson(json);
      if (tab == 1) return Hotel.fromJson(json);
      return TravelPackage.fromJson(json);
    }).toList();
  }

  void _refresh() => setState(() => items = _load());
  void _selectTab(int value) => setState(() {
        tab = value;
        category = 'All';
        items = _load();
      });

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: width < 650 ? 16 : 36,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.travel_explore,
                  color: Colors.white, size: 23)),
          const SizedBox(width: 11),
          const Text('TravelEase',
              style:
                  TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.6)),
        ]),
        actions: [
          if (width > 650)
            TextButton.icon(
                onPressed: () => _selectTab(0),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Explore')),
          if (width > 650)
            TextButton.icon(
                onPressed: () => _selectTab(2),
                icon: const Icon(Icons.luggage_outlined),
                label: const Text('Packages')),
          IconButton(
              tooltip: widget.darkMode
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              onPressed: widget.onToggleTheme,
              icon: Icon(widget.darkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded)),
          Padding(
              padding: const EdgeInsets.only(right: 22, left: 4),
              child: user == null
                  ? FilledButton.tonalIcon(
                      onPressed: _showAuth,
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Sign in'))
                  : PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'logout') _logout();
                      },
                      itemBuilder: (_) => [
                            PopupMenuItem(
                                value: 'logout',
                                child: Text('Sign out ${user!.name}'))
                          ],
                      child: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                              user!.name.isEmpty
                                  ? 'T'
                                  : user!.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white))))),
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _hero(width)),
        SliverToBoxAdapter(child: _browseSection(width)),
        FutureBuilder<List<dynamic>>(
          future: items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()));
            if (snapshot.hasError)
              return SliverToBoxAdapter(
                  child: _message(
                      Icons.cloud_off_outlined,
                      'We couldn’t reach the travel database',
                      'Check that the backend and MongoDB are running, then try again.',
                      'Retry',
                      _refresh));
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              final isSearch = search.isNotEmpty;
              return SliverToBoxAdapter(
                  child: _message(
                      isSearch
                          ? Icons.search_off_rounded
                          : Icons.travel_explore_rounded,
                      isSearch
                          ? 'No trips match “$search”'
                          : 'Your travel collection is waiting',
                      isSearch
                          ? 'Try a destination name such as Goa, Bali or Paris, or clear your search.'
                          : 'This database has no listings yet. From the project folder, run npm run seed to add sample destinations, hotels and packages. Seeding clears existing TravelEase records first.',
                      isSearch ? 'Clear search' : 'Refresh listings', () {
                if (isSearch) {
                  searchController.clear();
                  search = '';
                }
                _refresh();
              }));
            }
            return SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    width > 1200 ? 48 : 22, 8, width > 1200 ? 48 : 22, 48),
                sliver: SliverLayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent > 1050
                      ? 3
                      : constraints.crossAxisExtent > 650
                          ? 2
                          : 1;
                  return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                          (context, index) => _listingCard(data[index], index),
                          childCount: data.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 22,
                          mainAxisSpacing: 22,
                          childAspectRatio: columns == 1 ? 1.65 : 0.91));
                }));
          },
        ),
        SliverToBoxAdapter(child: _footer()),
      ]),
    );
  }

  Widget _hero(double width) => Container(
        margin: EdgeInsets.fromLTRB(
            width > 900 ? 36 : 14, 16, width > 900 ? 36 : 14, 0),
        height: width < 600 ? 430 : 410,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: AppColors.dark),
        child: Stack(fit: StackFit.expand, children: [
          Image.network(
              'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=2200&q=85',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.dark)),
          DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                Colors.black.withValues(alpha: .75),
                Colors.black.withValues(alpha: .24),
                Colors.black.withValues(alpha: .05)
              ]))),
          Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                              width: 620,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 13, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: .17),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: const Text(
                                            '✦  FIND YOUR NEXT GETAWAY',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.1))),
                                    const SizedBox(height: 18),
                                    Text('The world is closer\nthan you think.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            height: 1.05,
                                            fontSize: width < 600 ? 42 : 58,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -1.8)),
                                    const SizedBox(height: 14),
                                    const Text(
                                        'Discover places you’ll remember, stays that feel special, and journeys worth taking.',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            height: 1.5)),
                                    const SizedBox(height: 25),
                                    _searchBox(width),
                                  ])))))),
        ]),
      );

  Widget _searchBox(double width) => Container(
        padding: const EdgeInsets.fromLTRB(14, 5, 7, 5),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15)),
        child: Row(children: [
          Icon(Icons.search,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
              child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) {
                    search = v.trim();
                    _refresh();
                  },
                  decoration: InputDecoration(
                      hintText: 'Where would you like to go?',
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant)))),
          const SizedBox(width: 8),
          FilledButton(
              onPressed: () {
                search = searchController.text.trim();
                _refresh();
                FocusScope.of(context).unfocus();
              },
              style: FilledButton.styleFrom(
                  minimumSize: Size(width < 600 ? 46 : 112, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 16)),
              child: width < 600
                  ? const Icon(Icons.arrow_forward)
                  : const Text('Search'))
        ]),
      );

  Widget _browseSection(double width) {
    final categories = tab == 0
        ? ['All', ...categoriesList]
        : tab == 1
            ? ['All', ...hotelCategories]
            : ['All'];
    return Padding(
        padding: EdgeInsets.fromLTRB(
            width > 1200 ? 48 : 22, 34, width > 1200 ? 48 : 22, 18),
        child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CURATED FOR YOU',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5)),
                                  const SizedBox(height: 7),
                                  Text(
                                      tab == 0
                                          ? 'Explore destinations'
                                          : tab == 1
                                              ? 'Find your stay'
                                              : 'Trips made memorable',
                                      style: const TextStyle(
                                          fontSize: 27,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -.6))
                                ]),
                            if (width > 580)
                              Row(children: [
                                for (var i = 0; i < 3; i++)
                                  Padding(
                                      padding: const EdgeInsets.only(left: 7),
                                      child: ChoiceChip(
                                          label: Text([
                                            'Places',
                                            'Hotels',
                                            'Packages'
                                          ][i]),
                                          selected: tab == i,
                                          onSelected: (_) => _selectTab(i)))
                              ])
                          ]),
                      if (width <= 580)
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(children: [
                              for (var i = 0; i < 3; i++)
                                Padding(
                                    padding: const EdgeInsets.only(right: 7),
                                    child: ChoiceChip(
                                        label: Text([
                                          'Places',
                                          'Hotels',
                                          'Packages'
                                        ][i]),
                                        selected: tab == i,
                                        onSelected: (_) => _selectTab(i)))
                            ])),
                      if (categories.length > 1)
                        Padding(
                            padding: const EdgeInsets.only(top: 13),
                            child: Wrap(
                                spacing: 8,
                                children: categories
                                    .map((c) => ChoiceChip(
                                        label: Text(c),
                                        selected: category == c,
                                        onSelected: (_) {
                                          setState(() {
                                            category = c;
                                            items = _load();
                                          });
                                        }))
                                    .toList())),
                    ]))));
  }

  Widget _listingCard(dynamic value, int index) {
    final title = value is Destination
        ? value.name
        : value is Hotel
            ? value.name
            : (value as TravelPackage).name;
    final photo = value is Destination
        ? value.image
        : value is Hotel
            ? value.image
            : (value as TravelPackage).image;
    final subtitle = value is Destination
        ? '${value.country} · ${value.category}'
        : value is Hotel
            ? value.location
            : '${value.destinationName} · ${value.duration}';
    final price = value is Destination
        ? value.price
        : value is Hotel
            ? value.pricePerNight
            : (value as TravelPackage).price;
    final rating = value is Destination
        ? value.rating
        : value is Hotel
            ? value.rating
            : (value as TravelPackage).rating;
    final description = value is Destination
        ? value.shortDescription
        : value is Hotel
            ? value.description
            : (value as TravelPackage).description;
    final image = photo.isEmpty ? placeholderImage : photo;
    return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: InkWell(
            onTap: () => _showDetails(value),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  flex: 6,
                  child: Stack(fit: StackFit.expand, children: [
                    Image.network(image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: Colors.blueGrey.shade100,
                            child: const Icon(Icons.landscape, size: 52))),
                    Positioned(
                        left: 13,
                        top: 13,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .94),
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                                tab == 0
                                    ? 'DESTINATION'
                                    : tab == 1
                                        ? 'TOP RATED STAY'
                                        : 'HANDPICKED TRIP',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dark,
                                    letterSpacing: .5)))),
                    Positioned(
                        right: 13,
                        top: 13,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .94),
                                borderRadius: BorderRadius.circular(30)),
                            child: Row(children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: Color(0xFFFFA629)),
                              const SizedBox(width: 3),
                              Text(rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark))
                            ])))
                  ])),
              Expanded(
                  flex: 5,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subtitle.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 5),
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 18)),
                            const SizedBox(height: 3),
                            Expanded(
                                child: Text(
                                    description.isEmpty
                                        ? 'A memorable getaway is waiting for you.'
                                        : description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontSize: 12,
                                        height: 1.4))),
                            Row(children: [
                              Text('₹${price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18)),
                              Text(tab == 1 ? ' / night' : ' / person',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                              const Spacer(),
                              TextButton(
                                  onPressed: () => tab == 0
                                      ? _showDetails(value)
                                      : _book(value),
                                  child:
                                      Text(tab == 0 ? 'Explore' : 'Book now')),
                              const Icon(Icons.arrow_forward_rounded,
                                  size: 17, color: AppColors.primary)
                            ])
                          ]))),
            ])));
  }

  Widget _message(IconData icon, String title, String detail, String action,
          VoidCallback onPressed) =>
      Padding(
          padding: const EdgeInsets.fromLTRB(24, 35, 24, 60),
          child: Center(
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24)),
                  child: Column(children: [
                    Icon(icon, size: 42, color: AppColors.primary),
                    const SizedBox(height: 14),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 21)),
                    const SizedBox(height: 9),
                    Text(detail,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5)),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                        onPressed: onPressed,
                        icon: const Icon(Icons.refresh),
                        label: Text(action))
                  ]))));

  Widget _footer() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: const Center(
          child: Text('TravelEase  ·  Find your place in the world',
              style: TextStyle(fontWeight: FontWeight.w600))));

  void _showDetails(dynamic value) {
    final name = value is Destination
        ? value.name
        : value is Hotel
            ? value.name
            : (value as TravelPackage).name;
    final description = value is Destination
        ? value.description
        : value is Hotel
            ? value.description
            : (value as TravelPackage).description;
    final image = value is Destination
        ? value.image
        : value is Hotel
            ? value.image
            : (value as TravelPackage).image;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: SizedBox(
          width: 520,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image.isNotEmpty)
                  Image.network(image,
                      width: double.infinity,
                      height: 210,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(height: 80)),
                Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 23)),
                          const SizedBox(height: 8),
                          Text(description.isEmpty
                              ? 'A memorable getaway is waiting for you.'
                              : description),
                          const SizedBox(height: 16),
                          if (value is Destination)
                            Wrap(
                                spacing: 6,
                                children: value.attractions
                                    .take(4)
                                    .map((x) => Chip(label: Text(x)))
                                    .toList()),
                          if (value is TravelPackage) Text(value.duration),
                          if (value is Hotel)
                            Text(
                                '${value.stars} star stay · ${value.amenities.take(4).join(' · ')}'),
                          const SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('Close')),
                                if (value is Hotel || value is TravelPackage)
                                  FilledButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        _book(value);
                                      },
                                      child: const Text('Book this trip')),
                              ]),
                        ])),
              ]),
        ),
      ),
    );
  }

  Future<void> _showAuth() async {
    final email = TextEditingController();
    final password = TextEditingController();
    final name = TextEditingController();
    var registering = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(registering ? 'Create your account' : 'Welcome back'),
          content: SizedBox(
              width: 380,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (registering)
                  TextField(
                      controller: name,
                      decoration:
                          const InputDecoration(labelText: 'Full name')),
                const SizedBox(height: 10),
                TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 10),
                TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password')),
              ])),
          actions: [
            TextButton(
                onPressed: () =>
                    setDialogState(() => registering = !registering),
                child:
                    Text(registering ? 'I have an account' : 'Create account')),
            FilledButton(
                onPressed: () async {
                  try {
                    final result = await ApiService.post(
                        '/auth/${registering ? 'register' : 'login'}', {
                      'email': email.text.trim(),
                      'password': password.text,
                      if (registering) 'name': name.text.trim()
                    });
                    await ApiService.setToken(result['token'] as String?);
                    if (!mounted) return;
                    setState(() => user = AppUser.fromJson(
                        Map<String, dynamic>.from(result['user'] as Map)));
                    Navigator.pop(dialogContext);
                    _toast('You’re signed in. Happy travels!');
                  } catch (e) {
                    if (mounted) _toast(e.toString());
                  }
                },
                child: Text(registering ? 'Create account' : 'Sign in')),
          ],
        ),
      ),
    );
    email.dispose();
    password.dispose();
    name.dispose();
  }

  void _logout() async {
    await ApiService.setToken(null);
    if (mounted) setState(() => user = null);
  }

  Future<void> _book(dynamic value) async {
    if (user == null) {
      await _showAuth();
      if (user == null) return;
    }
    final travelDate = DateTime.now().add(const Duration(days: 7));
    final returnDate = travelDate.add(
        Duration(days: value is Hotel ? 2 : (value as TravelPackage).nights));
    final fullName = TextEditingController(text: user!.name);
    final email = TextEditingController(text: user!.email);
    final phone = TextEditingController(text: user!.phone);
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Confirm your trip'),
                content: SizedBox(
                    width: 400,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(value is Hotel
                              ? 'Stay at ${value.name}'
                              : 'Trip: ${(value as TravelPackage).name}'),
                          const SizedBox(height: 8),
                          Text(
                              'Starting ${travelDate.toLocal().toString().split(' ').first}'),
                          const SizedBox(height: 12),
                          TextField(
                              controller: fullName,
                              decoration: const InputDecoration(
                                  labelText: 'Full name')),
                          const SizedBox(height: 9),
                          TextField(
                              controller: email,
                              decoration:
                                  const InputDecoration(labelText: 'Email')),
                          const SizedBox(height: 9),
                          TextField(
                              controller: phone,
                              keyboardType: TextInputType.phone,
                              decoration:
                                  const InputDecoration(labelText: 'Phone'))
                        ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Confirm booking'))
                ]));
    if (confirmed == true && mounted) {
      try {
        await ApiService.post('/bookings', {
          'type': value is Hotel ? 'Hotel' : 'Package',
          'itemId': value.id,
          'travelDate': travelDate.toIso8601String(),
          if (value is Hotel) 'returnDate': returnDate.toIso8601String(),
          'travelers': 1,
          'rooms': 1,
          'fullName': fullName.text.trim(),
          'email': email.text.trim(),
          'phone': phone.text.trim()
        });
        _toast('Booking confirmed! You can view your trip in your account.');
      } catch (e) {
        _toast(e.toString());
      }
    }
    fullName.dispose();
    email.dispose();
    phone.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }
}

const categoriesList = [
  'Beaches',
  'Mountains',
  'Cities',
  'Adventure',
  'Luxury',
  'Cultural'
];
