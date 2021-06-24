import { apiInitializer } from "discourse/lib/api";
import NavItem from "discourse/models/nav-item";

export default apiInitializer("0.8", (api) => {
  api.addDiscoveryQueryParam("unseen", { replace: true, refreshModel: true });

  api.addNavigationBarItem({
    name: "unseen",
    before: "top",
    customFilter: () => {
      return !!api.getCurrentUser();
    },
    customHref: (category, args) => {
      const path = NavItem.pathFor("latest", args);
      return `${path}?unseen=true`;
    },
    forceActive: (category, args, router) => {
      const queryParams = router.currentRoute.queryParams;
      return (
        queryParams &&
        Object.keys(queryParams).length === 1 &&
        queryParams["unseen"] === "true"
      );
    },
  });
});
